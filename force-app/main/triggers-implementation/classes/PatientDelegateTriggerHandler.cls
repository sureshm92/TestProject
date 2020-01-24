/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateTriggerHandler {

    public static final String PATIENT_DELEGATE_ACTIVE_STATUS = 'Active';
    public static final String PATIENT_DELEGATE_ONHOLD_STATUS = 'On Hold';
    public static final String PATIENT_DELEGATE_DISCONNECTED_STATUS = 'Disconnected';

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class SetDefaultPatientDelegateStatus extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            setDefaultPatientStatus(newList);
        }

    }

    public class DeActivePatientDelegateUser extends TriggerHandler{

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            deActivePatientDelegateUser(newList, (Map<Id, Patient_Delegate__c>)oldMap);
        }

    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void setDefaultPatientStatus(List<Patient_Delegate__c> newList) {
        for (Patient_Delegate__c participantDelegate : newList) {
            participantDelegate.Status__c = PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS;
        }
    }

    @TestVisible
    private static void deActivePatientDelegateUser(List<Patient_Delegate__c> newList, Map<Id, Patient_Delegate__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Patient_Delegate__c participantDelegate : newList) {
            if (participantDelegate.Status__c != oldMap.get(participantDelegate.Id).Status__c &&
                    (PatientDelegateTriggerHandler.PATIENT_DELEGATE_ONHOLD_STATUS == participantDelegate.Status__c ||
                     PatientDelegateTriggerHandler.PATIENT_DELEGATE_DISCONNECTED_STATUS == participantDelegate.Status__c)) {
                contactIds.add(participantDelegate.Contact__c);
            }
        }

        if (!contactIds.isEmpty()) {
            List<User> users = [SELECT Id, IsActive FROM User WHERE ContactId IN :contactIds AND IsActive = true];
            for (User usr: users) {
                usr.IsActive = false;
            }

            if (!users.isEmpty() && !Test.isRunningTest()) {
                update users;
            }
        }
    }

}