/**
 * Created by Igor Malyuta on 25.03.2019.
 */

public class PatientDelegateRemote {

    @AuraEnabled
    public static String getYourPatientFirstName() {
        List<Participant__c> contacts = [
                SELECT First_Name__c
                FROM Participant__c
                WHERE Contact__r.Id = :PatientDelegateService.getDelegatePatientUserContactId()];

        return contacts.get(0).First_Name__c;
    }

    @AuraEnabled
    public static void withdrawDelegate(String delegate) {
        Contact contactToWithdraw = (Contact) JSON.deserialize(delegate, Contact.class);
        PatientDelegateService.resetDelegate(contactToWithdraw);
    }

    @AuraEnabled
    public static String getLogOutUrl() {
        return Site.getBaseUrl();
    }
}