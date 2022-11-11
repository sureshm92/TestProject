/**
 * Created by Andrii Kryvolap
 */

public without sharing class ProviderPaymentsService {
    public final static String ACTIVITY_TYPE_ORIENTATION = 'orientation';
    public final static String ACTIVITY_TYPE_MRR = 'screener1';

    /**
     * Logic moved to Screener response from PE due to multi screener implementation
    public static void checkPEForReimbursableActivities(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Participant_Enrollment__c> peWithMRRDateUpdatedFromHCP = new List<Participant_Enrollment__c>();
        Set<Id> studySiteIds = new Set<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (
                pe.Medical_Record_Review_Completed_Date__c != null &&
                (oldMap == null ||
                oldMap.get(pe.Id).Medical_Record_Review_Completed_Date__c !=
                pe.Medical_Record_Review_Completed_Date__c)
            ) {
                peWithMRRDateUpdatedFromHCP.add(pe);
                studySiteIds.add(pe.Study_Site__c);
            }
        }
        Map<Id, Study_Site__c> studySitesMap = new Map<Id, Study_Site__c>();
        if(!studySiteIds.isEmpty()){
            for (Study_Site__c ss : [
                SELECT Id, Billable_Code_CRM_Number__c, Protocol_ID__c, Principal_Investigator__c
                FROM Study_Site__c
                WHERE
                Id IN :studySiteIds
                AND Clinical_Trial_Profile__r.Sponsor_Pays_for_Referral_Activity__c = 'Yes'
                AND Billable_Code_CRM_Number__c != NULL
            ]) {
                studySitesMap.put(ss.Id, ss);
            }
        }
        List<Participant_Enrollment__c> peWithReimbursableActivities = new List<Participant_Enrollment__c>();
        Set<Id> providerContactIds = new Set<Id>();
        for (Participant_Enrollment__c pe : peWithMRRDateUpdatedFromHCP) {
            if (
                studySitesMap.containsKey(pe.Study_Site__c) &&
                (pe.HCP__C != null ||
                pe.Referral_Source__c != ParticipantEnrollmentService.PE_REFERRAL_SOURCE_EPR)
            ) {
                peWithReimbursableActivities.add(pe);
                if (pe.HCP__c != null) {
                    providerContactIds.add(pe.HCP_Contact_HCPEnroll__c);
                } else if (
                    pe.Referral_Source__c != ParticipantEnrollmentService.PE_REFERRAL_SOURCE_EPR
                ) {
                    providerContactIds.add(
                        studySitesMap.get(pe.Study_Site__c).Principal_Investigator__c
                    );
                }
            }
        }
        if (!peWithReimbursableActivities.isEmpty()) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>(
                [
                    SELECT
                        Id,
                        FirstName,
                        LastName,
                        MailingPostalCode,
                        MailingCountry,
                        MailingState,
                        MailingCity,
                        MailingStreet,
                        Provider_ID__c
                    FROM Contact
                    WHERE Id IN :providerContactIds
                ]
            );
            createProviderPaymentsForPEs(peWithReimbursableActivities, studySitesMap, contactMap);
        }
    }
    **/
    public static void checkPEForReimbursableActivities(
        List<Participant_PrescreenerResponse__c> newList,
        Map<Id, Participant_PrescreenerResponse__c> oldMap
    ) {

        Map<Id, DateTime> peMrrCompletedDateMap = new Map<Id, DateTime>();
        Set<Id> participantEnrollmentIds = new Set<Id>();

        for(Participant_PrescreenerResponse__c response : newList) {

            if ((response.MRR__c == true || response.MRR_EPR__c == true) &&
                response.Completed_Date__c != null &&
                (oldMap == null ||
                oldMap.get(response.Id).Completed_Date__c !=
                response.Completed_Date__c)
            ) {
                participantEnrollmentIds.add(response.Participant_enrollment__c);
                peMrrCompletedDateMap.put(response.Participant_enrollment__c, response.Completed_Date__c);
            }
        }

        if(participantEnrollmentIds.isEmpty() == false) {

            List<Participant_Enrollment__c> peWithMRRDateUpdatedFromHCP = new List<Participant_Enrollment__c>();
            Set<Id> studySiteIds = new Set<Id>();
            for (Participant_Enrollment__c pe : [
                SELECT Id, Name, HCP__c, HCP_Contact_HCPEnroll__c, Patient_ID__c,
                    Referral_Source__c, Screening_ID__c, Study_Site__c
                FROM Participant_Enrollment__c
                WHERE Id IN :participantEnrollmentIds
            ]) {
                
                peWithMRRDateUpdatedFromHCP.add(pe);
                studySiteIds.add(pe.Study_Site__c);
            }

            Map<Id, Study_Site__c> studySitesMap = new Map<Id, Study_Site__c>();
            if(!studySiteIds.isEmpty()){
                for (Study_Site__c ss : [
                    SELECT Id, Billable_Code_CRM_Number__c, Protocol_ID__c, Principal_Investigator__c
                    FROM Study_Site__c
                    WHERE Id IN :studySiteIds
                        AND Clinical_Trial_Profile__r.Sponsor_Pays_for_Referral_Activity__c = 'Yes'
                        AND Billable_Code_CRM_Number__c != NULL
                ]) {
                    studySitesMap.put(ss.Id, ss);
                }
            }
            List<Participant_Enrollment__c> peWithReimbursableActivities = new List<Participant_Enrollment__c>();
            Set<Id> providerContactIds = new Set<Id>();
            for (Participant_Enrollment__c pe : peWithMRRDateUpdatedFromHCP) {
                if (
                    studySitesMap.containsKey(pe.Study_Site__c) &&
                    (pe.HCP__C != null ||
                    pe.Referral_Source__c != ParticipantEnrollmentService.PE_REFERRAL_SOURCE_EPR)
                ) {
                    peWithReimbursableActivities.add(pe);
                    if (pe.HCP__c != null) {
                        providerContactIds.add(pe.HCP_Contact_HCPEnroll__c);
                    } else if (
                        pe.Referral_Source__c != ParticipantEnrollmentService.PE_REFERRAL_SOURCE_EPR
                    ) {
                        providerContactIds.add(
                            studySitesMap.get(pe.Study_Site__c).Principal_Investigator__c
                        );
                    }
                }
            }
            if (!peWithReimbursableActivities.isEmpty()) {
                Map<Id, Contact> contactMap = new Map<Id, Contact>(
                    [
                        SELECT
                            Id,
                            FirstName,
                            LastName,
                            MailingPostalCode,
                            MailingCountry,
                            MailingState,
                            MailingCity,
                            MailingStreet,
                            Provider_ID__c
                        FROM Contact
                        WHERE Id IN :providerContactIds
                    ]
                );
                createProviderPaymentsForPEs(
                    peWithReimbursableActivities, 
                    studySitesMap, 
                    contactMap,
                    peMrrCompletedDateMap
                );
            }
        }
    }

    public static void checkHCPEForReimbursableActivities(
        List<HCP_Enrollment__c> newList,
        Map<Id, HCP_Enrollment__c> oldMap
    ) {
        List<HCP_Enrollment__c> hcpeWithOrientationDateUpdated = new List<HCP_Enrollment__c>();
        Set<Id> studySiteIds = new Set<Id>();
        for (HCP_Enrollment__c hcpe : newList) {
            if (
                hcpe.Orientation_Date__c != null &&
                (oldMap == null ||
                oldMap.get(hcpe.Id).Orientation_Date__c != hcpe.Orientation_Date__c)
            ) {
                hcpeWithOrientationDateUpdated.add(hcpe);
                studySiteIds.add(hcpe.Study_Site__c);
            }
        }
        Map<Id, Study_Site__c> studySitesMap = new Map<Id, Study_Site__c>();
        for (Study_Site__c ss : [
            SELECT Id, Billable_Code_CRM_Number__c, Protocol_ID__c
            FROM Study_Site__c
            WHERE
                Id IN :studySiteIds
                AND Clinical_Trial_Profile__r.Sponsor_Pays_for_Referral_Activity__c = 'Yes'
                AND Billable_Code_CRM_Number__c != NULL
        ]) {
            studySitesMap.put(ss.Id, ss);
        }
        List<HCP_Enrollment__c> hcpeWithReimbursableActivities = new List<HCP_Enrollment__c>();
        Set<Id> hcpContactIds = new Set<Id>();
        for (HCP_Enrollment__c hcpe : hcpeWithOrientationDateUpdated) {
            if (studySitesMap.containsKey(hcpe.Study_Site__c)) {
                hcpContactIds.add(hcpe.HCP_Contact__c);
                hcpeWithReimbursableActivities.add(hcpe);
            }
        }
        if (!hcpeWithReimbursableActivities.isEmpty()) {
            Map<Id, Contact> contactMap = new Map<Id, Contact>(
                [
                    SELECT
                        Id,
                        FirstName,
                        LastName,
                        MailingPostalCode,
                        MailingCountry,
                        MailingState,
                        MailingCity,
                        MailingStreet,
                        Provider_ID__c
                    FROM Contact
                    WHERE Id IN :hcpContactIds
                ]
            );
            createProviderPaymentsForHCPEs(
                hcpeWithReimbursableActivities,
                studySitesMap,
                contactMap
            );
        }
    }

    private static void createProviderPaymentsForPEs(
        List<Participant_Enrollment__c> participantEnrollments,
        Map<Id, Study_Site__c> studySitesMap,
        Map<Id, Contact> contactMap,
        Map<Id, DateTime> peMrrCompletedDateMap
    ) {
        List<Provider_Payment__c> paymentsToCreate = new List<Provider_Payment__c>();
        for (Participant_Enrollment__c pe : participantEnrollments) {
            Contact providerContact;
            if (pe.HCP__c != null) {
                providerContact = contactMap.get(pe.HCP_Contact_HCPEnroll__c);
            } else {
                providerContact = contactMap.get(
                    studySitesMap.get(pe.Study_Site__c).Principal_Investigator__c
                );
            }
            Provider_Payment__c payment = new Provider_Payment__c();
            payment.Activity__c = ACTIVITY_TYPE_MRR;
            payment.Billable_Code__c = studySitesMap.get(pe.Study_Site__c)
                .Billable_Code_CRM_Number__c;
            payment.Study_Code__c = studySitesMap.get(pe.Study_Site__c).Protocol_ID__c;
            payment.Patient_ID__c = pe.Patient_ID__c;
            payment.Randomization_ID__c = pe.Screening_ID__c;
            payment.Physicians_Name__c = providerContact.FirstName + ' ' + providerContact.LastName;
            payment.Activity_Date__c = peMrrCompletedDateMap.get(pe.Id).format(
                'MM/dd/yyyy'
            );
            payment.Referral_Id__c = pe.Name;
            payment.Provider_Street_Address__c = providerContact.MailingStreet;
            payment.Provider_City__c = providerContact.MailingCity;
            payment.Provider_State__c = providerContact.MailingState;
            payment.Provider_Country__c = providerContact.MailingCountry;
            payment.Provider_Postal_Code__c = providerContact.MailingPostalCode;
            payment.Provider_ID__c = providerContact.Provider_ID__c;
            paymentsToCreate.add(payment);
        }
        insert paymentsToCreate;
    }

    private static void createProviderPaymentsForHCPEs(
        List<HCP_Enrollment__c> hcpEnrollments,
        Map<Id, Study_Site__c> studySitesMap,
        Map<Id, Contact> contactMap
    ) {
        List<Provider_Payment__c> paymentsToCreate = new List<Provider_Payment__c>();
        for (HCP_Enrollment__c hcpe : hcpEnrollments) {
            Contact hcpContact = contactMap.get(hcpe.HCP_Contact__c);
            Provider_Payment__c payment = new Provider_Payment__c();
            payment.Activity__c = ACTIVITY_TYPE_ORIENTATION;
            payment.Billable_Code__c = studySitesMap.get(hcpe.Study_Site__c)
                .Billable_Code_CRM_Number__c;
            payment.Study_Code__c = studySitesMap.get(hcpe.Study_Site__c).Protocol_ID__c;
            payment.Physicians_Name__c = hcpe.HCP_Name__c;
            payment.Activity_Date__c = hcpe.Orientation_Date__c.format();
            payment.Provider_Street_Address__c = hcpContact.MailingStreet;
            payment.Provider_City__c = hcpContact.MailingCity;
            payment.Provider_State__c = hcpContact.MailingState;
            payment.Provider_Country__c = hcpContact.MailingCountry;
            payment.Provider_Postal_Code__c = hcpContact.MailingPostalCode;
            payment.Provider_ID__c = hcpContact.Provider_ID__c;
            paymentsToCreate.add(payment);
        }
        insert paymentsToCreate;
    }
}