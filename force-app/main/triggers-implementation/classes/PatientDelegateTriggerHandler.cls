/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateTriggerHandler {

    public static final String PATIENT_DELEGATE_ACTIVE_STATUS = 'Active';
    public static final String PATIENT_DELEGATE_ONHOLD_STATUS = 'On Hold';
    public static final String PATIENT_DELEGATE_DISCONNECTED_STATUS = 'Disconnected';

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class SetDefaultPatientDelegateStatusHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            setDefaultPatientStatus(newList);
        }

    }

    public class UpdateUserStatusHandler extends TriggerHandler{

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updateUserStatus(newList, (Map<Id, Patient_Delegate__c>)oldMap);
        }

    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void setDefaultPatientStatus(List<Patient_Delegate__c> newList) {
        for (Patient_Delegate__c participantDelegate : newList) {
            participantDelegate.Status__c = PATIENT_DELEGATE_ACTIVE_STATUS;
        }
    }

    @TestVisible
    private static void updateUserStatus(List<Patient_Delegate__c> newList, Map<Id, Patient_Delegate__c> oldMap) {
        Set<Id> contactIds = new Set<Id>();
        for (Patient_Delegate__c pd : newList) {
            if (pd.Status__c != oldMap.get(pd.Id).Status__c) {
                contactIds.add(pd.Contact__c);
            }
        }
    
        Map<Id, Boolean> isActiveContactsMap = new Map<Id, Boolean>();
        List<Contact> delegates = [SELECT Id, (SELECT Id, Status__c FROM Contacts__r) FROM Contact WHERE Id IN: contactIds];
        for(Contact contact : delegates){
            Boolean isActive = false;
            for(Patient_Delegate__c pd : contact.Contacts__r){
                if(pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS){
                    isActive = true;
                    break;
                }
            }
            isActiveContactsMap.put(contact.Id, isActive);
        }
    
        updateUsersStatusFuture(isActiveContactsMap);
    }

    @Future
    private static void updateUsersStatusFuture(Map<Id, Boolean> isActiveContactsMap) {
        if(isActiveContactsMap.isEmpty()) return ;
        List<User> users = [
                SELECT Id, IsActive, ContactId
                FROM User
                WHERE ContactId IN :isActiveContactsMap.keySet()
        ];
        for (User usr: users) usr.IsActive = isActiveContactsMap.get(usr.ContactId);
        if (!users.isEmpty()/* && !Test.isRunningTest()*/) {
            update users;
        }
    }

}