/**
 * Created by Leonid Bartenev
 */

public class PatientDelegateService {
    public class PatientDelegateServiceException extends Exception {
    }

    //Make sure it is Patient_Delegate__c
    public static Boolean isPatientDelegate() {
        Contact userContact = CommunityService.getUserContact();
        List<Patient_Delegate__c> patientDelegate = [
                SELECT Contact__r.Id
                FROM Patient_Delegate__c
                WHERE Contact__r.Id = :userContact.Id
        ];

        if(patientDelegate.isEmpty())
            return false;

        return patientDelegate.get(0).Contact__r.Id == userContact.Id;
    }

    public static Id getDelegatePatientUserId(){
        List<User> user = [
                SELECT  Id
                FROM    User
                WHERE   ContactId = :getDelegatePatientUserContactId()
                LIMIT   1
        ];
        if(user.isEmpty()){
            AuraHelper.throwException(new PatientDelegateServiceException('Contact Delegate has no Patient'));
        }
        return user[0].Id;
    }

    public static Id getDelegatePatientUserContactId() {
        if (!isPatientDelegate())
            AuraHelper.throwException(new PatientDelegateServiceException('Contact userType not Delegate'));

        List<Patient_Delegate__c> patientDelegate = [
                SELECT Participant__r.Contact__r.Id
                FROM Patient_Delegate__c
                WHERE Contact__r.Id = :CommunityService.getUserContact().Id
        ];
        return patientDelegate.get(0).Participant__r.Contact__r.Id;
    }
    
    public static List<Contact> getDelegateContacts() {
        return getDelegateContacts(CommunityService.getUserContact().Id);
    }
    
    public static List<Contact> getDelegateContacts(Id participantContactId) {
        List<Contact> contacts = new List<Contact>();
        for (Patient_Delegate__c pd : getPatientDelegates(participantContactId)) contacts.add(pd.Contact__r);
        return contacts;
    }
    
    public static List<Id> getDelegatedContactIds() {
        return getDelegatedContactIds(CommunityService.getUserContact().Id);
    }
    
    public static List<Id> getDelegatedContactIds(Id participantContactId) {
        List<Id> conIds = new List<Id>();
        for (Contact con : getDelegateContacts(participantContactId)) conIds.add(con.Id);
        return conIds;
    }
    
    public static List<Id> getDelegatedParticipantIds(){
        List<Id> patientIds = new List<Id>();
        for(Patient_Delegate__c pd : getPatientDelegates()) patientIds.add(pd.Participant__c);
        return patientIds;
    }

    public static List<Id> getDelegatedParticipantUserIds(){
        List<Id> userIds = new List<Id>();
        Id contactId;
        if(ParticipantService.getParticipantState().isDelegate){
            contactId = getDelegatePatientUserContactId();
        } else {
            contactId = CommunityService.getUserContact().Id;
        }
        List<User> users = [
                SELECT  Id
                FROM    User
                WHERE   ContactId IN: getDelegatedContactIds(contactId)
        ];
        for(User user: users){
            userIds.add(user.Id);
        }
        return userIds;
    }

    public static List<Patient_Delegate__c> getPatientDelegates() {
        if(ParticipantService.getParticipantState().isDelegate){
            return getPatientDelegates(getDelegatePatientUserContactId());
        }
        return getPatientDelegates(CommunityService.getUserContact().Id);
    }
    
    public static List<Patient_Delegate__c> getPatientDelegates(Id participantContactId){
        return [
                SELECT
                        Id,
                        Participant__c,
                        Contact__c,
                        Contact__r.Name,
                        Contact__r.FirstName,
                        Contact__r.LastName,
                        Contact__r.Email,
                        Contact__r.Participant_Opt_In_Status_Emails__c,
                        Contact__r.HCP_Opt_In_Patient_Status_Emails__c,
                        Contact__r.HCP_Opt_In_Study_Emails__c,
                        Contact__r.HCP_Opt_In_Referral_Status_Emails__c
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c = : participantContactId
        ];
    }

    public static void createPatientDelegate(Contact newDelegate) {
        if (getDelegatedContactIds().contains(newDelegate.Id)){
            throw new PatientDelegateServiceException(Label.PG_PST_L_Delegates_WrongAdd);
        }
        List<Participant__c> participant = [
                SELECT Id
                FROM Participant__c
                WHERE Contact__c = :CommunityService.getUserContact().Id
        ];
        
        if(participant.size() == 0) throw new PatientDelegateServiceException('Wrong contact: ' + CommunityService.getUserContact().Id);

        Patient_Delegate__c delegate = new Patient_Delegate__c(
                Contact__c = newDelegate.Id,
                Participant__c = participant.get(0).Id
        );
        insert delegate;
    }

    public static void resetDelegate(Contact delegate) {
        delegate.userCommunityMode__c = null;
        delegate.userCommunytyType__c = null;
        delegate.UserCommunityIsDelegate__c = false;
        update delegate;

        List<Patient_Delegate__c> patientDelegate = [
                SELECT Id
                FROM Patient_Delegate__c
                WHERE Contact__c =: delegate.Id
        ];
        delete patientDelegate.get(0);
    }
}

