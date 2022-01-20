/**
 * Created by RAMukhamadeev on 2019-03-04.
 */

public without sharing class LeadConversionHelper {
    public static String LEAD_STATUS_QUALIFIED_AND_SEND_INVITATION = 'Qualified and Send Invitation';

    public static void afterLeadsUpdate(
        List<Lead> newLeads,
        Map<Id, Lead> oldLeadsMap,
        Map<Id, Lead> newLeadsMap
    ) {
        System.debug('newLeads: ' + newLeads);
        // extract only converted leads
        List<Lead> convertedLeads = getConvertedLeads(newLeads, oldLeadsMap);

        // create HCP_Enrollment__c records on lead conversion
        Map<Id, HCP_Enrollment__c> leadConvertedToEnrollmentMap = insertEnrollments(convertedLeads);

        // create contacts
        Map<Id, Map<String, Contact>> accountPOCMap = getAccountPOCMap(convertedLeads);
        Map<Id, Contact> leadPOCMap = createContacts(convertedLeads, accountPOCMap);

        // insert new Point_of_Contact__c records
        insertPointOfContacts(convertedLeads, leadPOCMap);

        // update Lead with Converted_to_HCP__c lookup
        updateLeadsWithHCPEnrollments(leadConvertedToEnrollmentMap);

        // update National_ID__c records with Contact__c lookup
        updateNationalIds(convertedLeads, newLeadsMap);

        // update Material_Sent__c records with HCP_Enrollment__c lookup
        updateMaterialsSent(convertedLeads, newLeadsMap, leadConvertedToEnrollmentMap);

        // update contacts Without Study Site (setting user community type = HCP)
        updateContactsWithoutStudySite(convertedLeads);

        // create portal users
        createPortalUsersWithoutStudy(convertedLeads);
    }

    public static void createPortalUsersWithoutStudy(List<Lead> convertedLeads) {
        Set<Id> contactsWithoutStudySite = new Set<Id>();
        for (Lead lead : convertedLeads) {
            if (
                lead.Study_Site__c == null &&
                lead.Status == LEAD_STATUS_QUALIFIED_AND_SEND_INVITATION
            ) {
                contactsWithoutStudySite.add(lead.ConvertedContactId);
            }
        }
        if (!contactsWithoutStudySite.isEmpty()) {
            Map<Id, User> communityUsersMap = new Map<Id, User>();
            for (
                User usr : CommunityService.getCommunityUsersByContactIds(contactsWithoutStudySite)
            ) {
                communityUsersMap.put(usr.ContactId, usr);
            }

            Set<Id> contactIdsForCreateUser = new Set<Id>();
            for (Lead lead : convertedLeads) {
                if (!communityUsersMap.containsKey(lead.ConvertedContactId)) {
                    contactIdsForCreateUser.add(lead.ConvertedContactId);
                }
            }
            if (!contactIdsForCreateUser.isEmpty()) {
                ((CommunityService) ClassFactory.newInstance(CommunityService.class))
                    .createPortalUsers(contactIdsForCreateUser);
            }
        }
    }

    public static void updateContactsWithoutStudySite(List<Lead> convertedLeads) {
        Set<Id> contactsWithoutStudySite = new Set<Id>();
        for (Lead lead : convertedLeads) {
            if (lead.Study_Site__c == null) {
                contactsWithoutStudySite.add(lead.ConvertedContactId);
            }
        }
        if (!contactsWithoutStudySite.isEmpty()) {
            List<Contact> toUpdateContacts = new List<Contact>();
            for (Id contactId : contactsWithoutStudySite) {
                toUpdateContacts.add(
                    new Contact(
                        Id = contactId,
                        userCommunityMode__c = CommunityService.USER_MODE_HCP,
                        userCommunytyType__c = CommunityService.USER_MODE_HCP
                    )
                );
            }
            update toUpdateContacts;
        }
    }

    private static List<Lead> getConvertedLeads(List<Lead> newLeads, Map<Id, Lead> oldLeadsMap) {
        List<Lead> convertedLeads = new List<Lead>();
        for (Lead lead : newLeads) {
            if (lead.IsConverted && !(oldLeadsMap.get(lead.Id).IsConverted)) {
                convertedLeads.add(lead);
            }
        }
        return convertedLeads;
    }

    public static Map<Id, HCP_Enrollment__c> insertEnrollments(List<Lead> convertedLeads) {
        Map<Id, HCP_Enrollment__c> leadConvertedToEnrollmentMap = new Map<Id, HCP_Enrollment__c>();
        List<HCP_Enrollment__c> hcpEnrollmentsToCreate = new List<HCP_Enrollment__c>();
        for (Lead lead : convertedLeads) {
            if (lead.Study_Site__c != null) {
                String hcpeStatus;
                if (lead.Status == LEAD_STATUS_QUALIFIED_AND_SEND_INVITATION) {
                    hcpeStatus = HCPEnrollmentService.HCP_S_INVITATION_SENT;
                }

                HCP_Enrollment__c hcpe = new HCP_Enrollment__c(
                    Study_Site__c = lead.Study_Site__c,
                    HCP_Contact__c = lead.ConvertedContactId,
                    HCP_Referral_Source__c = lead.HCP_Referral_Source__c,
                    Patient_Count__c = lead.Patient_Count__c,
                    Pre_Screened_Count__c = lead.Pre_Screened_Count__c,
                    Pre_Screened_and_Did_Not_Qualify_Count__c = lead.Pre_Screened_and_Did_Not_Qualify_Count__c,
                    Status__c = hcpeStatus,
                    Degrees_of_Separation__c = lead.Degrees_Of_Separation__c
                );
                leadConvertedToEnrollmentMap.put(lead.Id, hcpe);
                hcpEnrollmentsToCreate.add(hcpe);
            }
        }
        if (!hcpEnrollmentsToCreate.isEmpty()) {
            insert hcpEnrollmentsToCreate;
        }
        return leadConvertedToEnrollmentMap;
    }

    private static void updateMaterialsSent(
        List<Lead> convertedLeads,
        Map<Id, Lead> newLeadsMap,
        Map<Id, HCP_Enrollment__c> leadConvertedToEnrollmentMap
    ) {
        List<Material_Sent__c> materialsToUpdate = new List<Material_Sent__c>();
        for (Material_Sent__c material : [
            SELECT Id, Lead__c, Contact__c
            FROM Material_Sent__c
            WHERE Lead__c IN :convertedLeads
        ]) {
            material.Contact__c = newLeadsMap.get(material.Lead__c).ConvertedContactId;
            HCP_Enrollment__c currEnrollment = leadConvertedToEnrollmentMap.get(material.Lead__c);
            if (currEnrollment != null) {
                material.HCP_Enrollment__c = currEnrollment.Id;
            }
            materialsToUpdate.add(material);
        }
        if (!materialsToUpdate.isEmpty()) {
            update materialsToUpdate;
        }
    }

    private static void updateNationalIds(List<Lead> convertedLeads, Map<Id, Lead> newLeadsMap) {
        List<National_ID__c> nidsToUpdate = new List<National_ID__c>();
        for (National_ID__c lnid : [
            SELECT Id, Lead__c, Contact__c
            FROM National_ID__c
            WHERE Lead__c IN :convertedLeads
        ]) {
            lnid.Contact__c = newLeadsMap.get(lnid.Lead__c).ConvertedContactId;
            nidsToUpdate.add(lnid);
        }
        if (!nidsToUpdate.isEmpty()) {
            update nidsToUpdate;
        }
    }

    public static void updateLeadsWithHCPEnrollments(
        Map<Id, HCP_Enrollment__c> leadConvertedToEnrollmentMap
    ) {
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Lead lead : [
            SELECT Id, Converted_to_HCP__c
            FROM Lead
            WHERE Id IN :leadConvertedToEnrollmentMap.keySet()
        ]) {
            HCP_Enrollment__c currEnrollment = leadConvertedToEnrollmentMap.get(lead.Id);
            if (currEnrollment != null) {
                lead.Converted_to_HCP__c = currEnrollment.Id;
            }
            leadsToUpdate.add(lead);
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
    }

    public static void insertPointOfContacts(
        List<Lead> convertedLeads,
        Map<Id, Contact> leadPOCMap
    ) {
        List<Point_of_Contact__c> pocsToCreate = new List<Point_of_Contact__c>();
        for (Lead lead : convertedLeads) {
            if (!String.isBlank(lead.POC_Last_Name__c)) {
                Point_of_Contact__c poc = new Point_of_Contact__c(
                    Point_of_Contact_for_Account__c = lead.ConvertedAccountId,
                    Point_of_Contact_for__c = lead.ConvertedContactId,
                    Point_of_Contact_Type__c = lead.POC_Type__c,
                    Point_of_Contact_Type_Description__c = lead.POC_Type_Description__c,
                    Contact__c = leadPOCMap.get(lead.Id).Id
                );
                pocsToCreate.add(poc);
            }
        }
        if (!pocsToCreate.isEmpty()) {
            insert pocsToCreate;
        }
    }

    public static Map<Id, Contact> createContacts(
        List<Lead> convertedLeads,
        Map<Id, Map<String, Contact>> accountPOCMap
    ) {
        List<Contact> contactsToCreate = new List<Contact>();
        Map<Id, Contact> leadPOCMap = new Map<Id, Contact>();
        for (Lead lead : convertedLeads) {
            if (!String.isBlank(lead.POC_Last_Name__c)) {
                Contact poc;
                Map<String, Contact> contactsByNameMap = accountPOCMap.get(lead.ConvertedAccountId);
                if (contactsByNameMap != null)
                    poc = contactsByNameMap.get(
                        lead.POC_First_Name__c +
                        ' ' +
                        lead.POC_Last_Name__c
                    );
                if (poc == null) {
                    poc = new Contact(
                        Email = lead.POC_Email__c,
                        FirstName = lead.POC_First_Name__c,
                        LastName = lead.POC_Last_Name__c,
                        Phone = lead.POC_Phone__c,
                        AccountId = lead.ConvertedAccountId,
                        Contact_Method_Preference__c = lead.Contact_Method_Preference__c,
                        Language__c = lead.Language__c
                    );
                    contactsToCreate.add(poc);
                }
                leadPOCMap.put(lead.Id, poc);
            }
        }
        if (!contactsToCreate.isEmpty()) {
            insert contactsToCreate;
        }
        return leadPOCMap;
    }

    public static Map<Id, Map<String, Contact>> getAccountPOCMap(List<Lead> convertedLeads) {
        Set<Id> accountsForLeads = new Set<Id>();
        Set<String> pocFirstNames = new Set<String>();
        Set<String> pocLastNames = new Set<String>();
        for (Lead lead : convertedLeads) {
            if (!String.isBlank(lead.POC_Last_Name__c)) {
                accountsForLeads.add(lead.ConvertedAccountId);
                pocFirstNames.add(lead.POC_First_Name__c);
                pocLastNames.add(lead.POC_Last_Name__c);
            }
        }

        Map<Id, Map<String, Contact>> accountPOCMap = new Map<Id, Map<String, Contact>>();
        List<Contact> contacts = [
            SELECT Id, AccountId, Name
            FROM Contact
            WHERE
                AccountId IN :accountsForLeads
                AND FirstName IN :pocFirstNames
                AND LastName IN :pocLastNames
        ];
        for (Contact c : contacts) {
            Map<String, Contact> contactsByNameMap = accountPOCMap.get(c.AccountId);
            if (contactsByNameMap == null)
                contactsByNameMap = new Map<String, Contact>();
            contactsByNameMap.put(c.Name, c);
            accountPOCMap.put(c.AccountId, contactsByNameMap);
        }
        return accountPOCMap;
    }
}