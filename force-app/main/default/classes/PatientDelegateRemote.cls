/**
 * Created by Igor Malyuta on 25.03.2019.
 */

public without sharing class PatientDelegateRemote {

    @AuraEnabled
    public static String getYourPatientFirstName() {
        try{
            List<Participant__c> contacts = [
                    SELECT First_Name__c
                    FROM Participant__c
                    WHERE Id =: PatientDelegateService.getInstance().getParticipant().Id];
    
            return contacts.get(0).First_Name__c;
        }catch (Exception e){
            AuraHelper.throwException(e);
            return null;
        }
    }

    @AuraEnabled
    public static String getDelegateByContactId(String id) {
        try{
            return JSON.serialize(PatientDelegateService.getInstance().getDelegateContact(id));
        }catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void editPatientDelegateDetail(String delegate) {
        try {
            Contact editedDelegate = (Contact) JSON.deserialize(delegate, Contact.class);
            List<Contact> contactsWithSameEmail = [
                    SELECT Id
                    FROM Contact
                    WHERE Email = :editedDelegate.Email AND Id !=: editedDelegate.Id
            ];
            if(!contactsWithSameEmail.isEmpty()) {
                throw new PatientDelegateService.PatientDelegateServiceException(Label.PG_PST_L_Delegates_Email_Not_Uniq);
            }
            if (PatientDelegateService.getInstance().getDelegatedContactIds().contains(editedDelegate.Id)) {
                update editedDelegate;
            } else {
                throw new PatientDelegateService.PatientDelegateServiceException(Label.PG_PST_L_Delegates_Not_Patient_Delegate);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void withdrawDelegate(String contactId) {
        try{
            PatientDelegateService.getInstance().resetDelegate(contactId);
        }catch (Exception e){
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String isDelegate() {
        try{
            return ParticipantService.getInstance().getState().isDelegate ? 'TRUE' : 'FALSE';
        }catch (Exception e){
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getLogOutUrl() {
        return Site.getBaseUrl();
    }
}