/**
 * Created by Igor Malyuta on 25.03.2019.
 */

public class PatientDelegateRemote {

    @AuraEnabled
    public static String getYourPatientFirstName() {
        try{
            List<Participant__c> contacts = [
                    SELECT First_Name__c
                    FROM Participant__c
                    WHERE Contact__r.Id = :PatientDelegateService.getDelegatePatientUserContactId()];

            return contacts.get(0).First_Name__c;
        }catch (Exception e) {
            AuraHelper.throwException(e);
            return 'null';
        }
    }

    @AuraEnabled
    public static void withdrawDelegate(String delegate) {
        try{
            Contact contactToWithdraw = (Contact) JSON.deserialize(delegate, Contact.class);
            PatientDelegateService.resetDelegate(contactToWithdraw);
        }catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String isDelegate() {
        try{
            return ParticipantService.getParticipantState().isDelegate ? 'TRUE' : 'FALSE';
        }catch (Exception e) {
            AuraHelper.throwException(e);
            return 'null';
        }
    }

    @AuraEnabled
    public static String getLogOutUrl() {
        try{
            return Site.getBaseUrl();
        }catch (Exception e) {
            AuraHelper.throwException(e);
            return 'null';
        }
    }
}