/**
 * Created by Leonid Bartenev
 */

public class PatientDelegateService {
    
    public class PatientDelegateServiceException extends Exception {
    }
    
    public static List<Contact> delegates = new List<Contact>();
    public static Boolean isDelegate;
    public static Participant__c participant;
    
    static {
        List<Patient_Delegate__c> participantsPDList = [
                SELECT
                        Id,
                        Participant__r.Contact__c,
                        Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c,
                        Participant__r.First_Name__c,
                        Participant__r.Last_Name__c,
                        Contact__c
                FROM Patient_Delegate__c
                WHERE Contact__c = :CommunityService.getUserContact().Id
        ];
        isDelegate = participantsPDList.size() > 0;
        if (isDelegate) {
            participant = participantsPDList[0].Participant__r;
        } else {
            participant = [
                    SELECT
                            Id,
                            First_Name__c,
                            Last_Name__c,
                            Contact__c,
                            Contact__r.Participant_Opt_In_Status_Emails__c
                    FROM Participant__c
                    WHERE Contact__c = :CommunityService.getUserContact().Id
            ];
        }
        List<Patient_Delegate__c> delegatesPDList = getPatientDelegates(participant.Contact__c);
        for (Patient_Delegate__c pd : delegatesPDList) delegates.add(pd.Contact__r);
    }
    
    public static Id getDelegatePatientUserId() {
        List<User> user = [
                SELECT Id
                FROM User
                WHERE ContactId = :participant.Contact__c
                LIMIT 1
        ];
        if (user.isEmpty()) {
            throw new PatientDelegateServiceException('No user found for participant: '
                    + participant.First_Name__c + ' ' + participant.Last_Name__c);
        }
        return user[0].Id;
    }
    
    public static List<Contact> getDelegateContacts() {
        return delegates;
    }
    
    public static List<Contact> getDelegateContacts(Id participantContactId) {
        List<Contact> contacts = new List<Contact>();
        for (Patient_Delegate__c pd : getPatientDelegates(participantContactId)) contacts.add(pd.Contact__r);
        return contacts;
    }
    
    public static List<Id> getDelegatedContactIds() {
        return SObjectHelper.toIdsList(delegates);
    }
    
    public static List<Id> getDelegatedContactIds(Id participantContactId) {
        return SObjectHelper.toIdsList(getDelegateContacts(participantContactId));
    }
    
    public static List<Id> getDelegatedParticipantUserIds() {
        List<Id> userIds = new List<Id>();
        List<User> users = [
                SELECT Id
                FROM User
                WHERE ContactId IN:delegates
        ];
        for (User user : users) userIds.add(user.Id);
        return userIds;
    }
    
    public static List<Patient_Delegate__c> getPatientDelegates() {
        return getPatientDelegates(CommunityService.getUserContact().Id);
    }
    
    public static List<Patient_Delegate__c> getPatientDelegates(Id participantContactId) {
        return [
                SELECT
                        Id,
                        Participant__c,
                        Participant__r.Contact__c,
                        Participant__r.Contact__r.Name,
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
                WHERE Participant__r.Contact__c = :participantContactId
        ];
    }
    
    public static void createPatientDelegate(Contact newDelegate) {
        if (getDelegatedContactIds().contains(newDelegate.Id)) {
            throw new PatientDelegateServiceException(Label.PG_PST_L_Delegates_WrongAdd);
        }
        List<Participant__c> participant = [
                SELECT Id
                FROM Participant__c
                WHERE Contact__c = :CommunityService.getUserContact().Id
        ];
        
        if (participant.size() == 0) throw new PatientDelegateServiceException('Wrong contact: ' + CommunityService.getUserContact().Id);
        
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
                WHERE Contact__c = :delegate.Id
        ];
        delete patientDelegate.get(0);
    }
    
}

