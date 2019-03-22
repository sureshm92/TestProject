/**
 * Created by Leonid Bartenev
 */

public class PatientDelegateService {

    public class PatientDelegateServiceException extends Exception {
    }

    public static List<Contact> getDelegateContacts() {
        List<Contact> contacts = new List<Contact>();
        for (Patient_Delegate__c pd : getPatientDelegates()) contacts.add(pd.Contact__r);
        return contacts;
    }

    public static List<Id> getDelegatedParticipantIds() {
        List<Id> patientIds = new List<Id>();
        for (Patient_Delegate__c pd : getPatientDelegates()) patientIds.add(pd.Participant__c);
        return patientIds;
    }

    public static List<Patient_Delegate__c> getPatientDelegates() {
        return [
                SELECT
                        Id,
                        Contact__c,
                        Contact__r.Name,
                        Contact__r.FirstName,
                        Contact__r.LastName
                FROM Patient_Delegate__c
                WHERE Participant__r.Contact__c = :CommunityService.getUserContact().Id
        ];
    }

    public static List<Id> getDelegatedContactIds() {
        List<Id> conIds = new List<Id>();
        for (Contact con : getDelegateContacts()) conIds.add(con.Id);
        return conIds;
    }

    public static void createPatientDelegate(Contact newDelegate) {
        System.debug('DEBUG ContactId ' + newDelegate.Id);
        for (Id id : getDelegatedContactIds())
            System.debug('Id Delegated contact is ' + id);

        if (getDelegatedContactIds().contains(newDelegate.Id))
            throw new PatientDelegateServiceException(Label.PG_PST_L_Delegates_WrongAdd);

        System.debug('Contains ' + getDelegateContacts().contains(newDelegate));

        newDelegate.userCommunytyType__c = CommunityService.USER_MODE_DELEGATE;
        update newDelegate;

        List<Participant__c> participant = [
                SELECT Id
                FROM Participant__c
                WHERE Contact__c = :CommunityService.getUserContact().Id
        ];

        Patient_Delegate__c delegate = new Patient_Delegate__c(
                Contact__c = newDelegate.Id,
                Participant__c = participant.get(0).Id
        );
        insert delegate;

    }

    public static Contact resetDelegate(Contact delegate) {
        List<Patient_Delegate__c> patientDelegate = [
                SELECT Id
                FROM Patient_Delegate__c
                WHERE Contact__c = :delegate.Id
        ];
        delete patientDelegate.get(0);

        delegate.userCommunityMode__c = null;
        delegate.userCommunytyType__c = null;
        delegate.UserCommunityIsDelegate__c = false;
        update delegate;

        return delegate;
    }
}
