trigger LeadConversionTrigger on Lead (after update) {
    Set<String> convertedStatuses = new Set<String>{
            'Qualified', 'Qualified and Send Invitation'
    };
    List<Lead> convertedLeads = new List<Lead>();
    Set<Id> leadsIds = new Set<Id>();
    Set<Id> accountsForLeads = new Set<Id>();
    Set<String> pocFirstNames = new Set<String>();
    Set<String> pocLastNames = new Set<String>();
    List<HCP_Enrollment__c> hcpEnrollmentsToCreate = new List<HCP_Enrollment__c>();
    List<Contact> contactsToCreate = new List<Contact>();
    Map<Id, HCP_Enrollment__c> leadConvertedToEnrollementMap = new Map<Id, HCP_Enrollment__c>();

    //create HCPE on lead conversion:
    for (Lead lead : Trigger.new) {
        if (lead.IsConverted && !(Trigger.oldMap.get(lead.Id).IsConverted)) {
            convertedLeads.add(lead);
            leadsIds.add(lead.Id);
            if (lead.Study_Site__c == null) {
                throw new LeadConversionException('Study Site is required to Convert Lead');
            }
    
            String hcpeStatus;
            if(lead.Status == 'Qualified and Send Invitation') hcpeStatus = HCPEnrollmentService.HCP_S_INVITATION_SENT;
            
            HCP_Enrollment__c hcpe = new HCP_Enrollment__c(
                    Study_Site__c = lead.Study_Site__c,
                    HCP_Contact__c = lead.ConvertedContactId,
                    HCP_Referral_Source__c = lead.HCP_Referral_Source__c,
                    Patient_Count__c = lead.Patient_Count__c,
                    Pre_Screened_Count__c = lead.Pre_Screened_Count__c,
                    Pre_Screened_and_Did_Not_Qualify_Count__c = lead.Pre_Screened_and_Did_Not_Qualify_Count__c,
                    Status__c = hcpeStatus
            );
            leadConvertedToEnrollementMap.put(lead.Id, hcpe);
            hcpEnrollmentsToCreate.add(hcpe);
            if (!String.isBlank(lead.POC_Last_Name__c)) {
                accountsForLeads.add(lead.ConvertedAccountId);
                pocFirstNames.add(lead.POC_First_Name__c);
                pocLastNames.add(lead.POC_Last_Name__c);
            }
        }
    }
    insert hcpEnrollmentsToCreate;
    
    //group contacts by account and contact name:
    Map<Id, Map<String, Contact>> accountPOCMap = new Map<Id, Map<String, Contact>>();
    List<Contact> contacts = [
            SELECT Id, AccountId, Name
            FROM Contact
            WHERE AccountId IN :accountsForLeads
            AND FirstName IN :pocFirstNames
            AND LastName IN :pocLastNames
    ];
    for (Contact c : contacts) {
        Map<String, Contact> contactsByNameMap = accountPOCMap.get(c.AccountId);
        if (contactsByNameMap == null) contactsByNameMap = new Map<String, Contact>();
        contactsByNameMap.put(c.Name, c);
        accountPOCMap.put(c.AccountId, contactsByNameMap);
    }

    //create contacts:
    Map<Id, Contact> leadPOCMap = new Map<Id, Contact>();
    for (Lead lead : convertedLeads) {
        if (!String.isBlank(lead.POC_Last_Name__c)){
            Contact poc;
            Map<String, Contact> contactsByNameMap = accountPOCMap.get(lead.ConvertedAccountId);
            if(contactsByNameMap != null) poc = contactsByNameMap.get(lead.POC_First_Name__c + ' ' + lead.POC_Last_Name__c);
            if (poc == null){
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
    insert contactsToCreate;
    
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
    insert pocsToCreate;
    
    List<Lead> leadsToUpdate = new List<Lead>();
    for (Lead lead : [SELECT Id, Converted_to_HCP__c FROM Lead WHERE Id IN: leadConvertedToEnrollementMap.keySet()]) {
        lead.Converted_to_HCP__c = leadConvertedToEnrollementMap.get(lead.Id).Id;
        leadsToUpdate.add(lead);
    }
    update leadsToUpdate;

    List<National_ID__c> nidsToUpdate = new List<National_ID__c>();
    for (National_ID__c lnid : [SELECT Id, Lead__c, Contact__c FROM National_ID__c WHERE Lead__c IN :leadsIds]) {
        lnid.Contact__c = Trigger.newMap.get(lnid.Lead__c).ConvertedContactId;
        nidsToUpdate.add(lnid);
    }
    update nidsToUpdate;
    List<Material_Sent__c> materialsToUpdate = new List<Material_Sent__c>();
    for (Material_Sent__c material : [SELECT Id, Lead__c, Contact__c FROM Material_Sent__c WHERE Lead__c IN :leadsIds]) {
        material.Contact__c = Trigger.newMap.get(material.Lead__c).ConvertedContactId;
        material.HCP_Enrollment__c = leadConvertedToEnrollementMap.get(material.Lead__c).Id;
        materialsToUpdate.add(material);
    }
    update materialsToUpdate;
}