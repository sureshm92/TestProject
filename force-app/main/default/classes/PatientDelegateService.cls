/**
 * Created by Leonid Bartenev
 */

public class PatientDelegateService {

    public static List<Contact> getDelegateContacts(){
        List<Contact> contacts = new List<Contact>();
        for(Patient_Delegate__c pd : getPatientDelegates()) contacts.add(pd.Contact__r);
        return contacts;
    }
    
    public static List<Id> getDelegatedParticipantIds(){
        List<Patient_Delegate__c> patientDelegates = getPatientDelegates();
        List<Id> patientIds = new List<Id>();
        for(Patient_Delegate__c pd : getPatientDelegates()) patientIds.add(pd.Participant__c);
        return patientIds;
    }
    
    public static List<Patient_Delegate__c> getPatientDelegates(){
        return [
                SELECT
                        Id,
                        Participant__c,
                        Contact__c,
                        Contact__r.Name,
                        Contact__r.FirstName,
                        Contact__r.LastName
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c =: CommunityService.getUserContact().Id
        ];
    }

}
