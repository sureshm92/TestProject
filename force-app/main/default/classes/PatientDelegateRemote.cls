/**
 * Created by Igor Malyuta on 25.03.2019.
 */

public without sharing class PatientDelegateRemote {
    @AuraEnabled
    public static String getYourPatientFirstName() {
        try {
            if (ParticipantContext.isCurrentDelegate())
                return ParticipantContext.getCurrentParticipant().First_Name__c;
            return null;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getYourPatientLastName() {
        try {
            if (ParticipantContext.isCurrentDelegate())
                return ParticipantContext.getCurrentParticipant().Last_Name__c;
            return null;
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getDelegateByContactId(String id) {
        try {
            return JSON.serialize(PatientDelegateService.getInstance().getDelegateContact(id));
        } catch (Exception e) {
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
                WHERE Email = :editedDelegate.Email AND Id != :editedDelegate.Id
            ];
            if (!contactsWithSameEmail.isEmpty()) {
                throw new PatientDelegateService.PatientDelegateServiceException(
                    Label.PG_PST_L_Delegates_Email_Not_Uniq
                );
            }
            if (
                PatientDelegateService.getInstance().getDelegateContact(editedDelegate.Id) != null
            ) {
                update editedDelegate;
            } else {
                throw new PatientDelegateService.PatientDelegateServiceException(
                    Label.PG_PST_L_Delegates_Not_Patient_Delegate
                );
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void changeDelegateStatus(String contactId, Boolean isActive) {
        try {
            String status = isActive
                ? PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS
                : PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS;
            PatientDelegateService.changeStatus(contactId, status);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void withdrawDelegate(String contactId, Boolean removeHimself) {
        try {
            //PatientDelegateService.getInstance().resetDelegate(contactId, removeHimself);
            String status = 'Withdrawn';
            PatientDelegateService.changeStatus(contactId, status);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getLogOutUrl() {
        try {
            return Site.getBaseUrl();
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}
