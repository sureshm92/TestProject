

public with sharing class PatientDelegateService {

    public static List<Contact> getDelegateContacts() {
        List<Patient_Delegate__c> patientDelegates = [
                SELECT
                        Id,
                        Contact__c,
                        Contact__r.Name,
                        Contact__r.FirstName,
                        Contact__r.LastName
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c = :CommunityService.getUserContact().Id
        ];
        List<Contact> contacts = new List<Contact>();
        for (Patient_Delegate__c pd : patientDelegates) contacts.add(pd.Contact__r);
        return contacts;
    }
}