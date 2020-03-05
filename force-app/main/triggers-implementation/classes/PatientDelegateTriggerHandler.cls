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
    
    public class UpdatePermissionSetAssignments extends TriggerHandler{
    
        public override void afterInsert(List<SObject> newList) {
            updatePermissionSets(newList);
        }
    
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            updatePermissionSets(newList);
        }
    
        public override void afterDelete(List<SObject> oldList) {
            updatePermissionSets(oldList);
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
    
    private static void updatePermissionSets(List<Patient_Delegate__c> changedPDList){
        Set<Id> contactIds = new Set<Id>();
        for(Patient_Delegate__c pd : changedPDList) contactIds.add(pd.Contact__c);
        Action_AssignContactPermissions actionAssignContactPermissions = new Action_AssignContactPermissions();
        Patient_Delegate__c[] pdList = [
                SELECT Id, Contact__c, Participant__c
                FROM Patient_Delegate__c
                WHERE Contact__c IN: contactIds AND Status__c =: PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        Map<Id, Set<Id>> delegatedParticipantsMap = new Map<Id, Set<Id>>();
        Set<Id> allDelegatedParticipantIds = new Set<Id>();
        for(Patient_Delegate__c pd : pdList){
            Set<Id> delegatedParticipants = delegatedParticipantsMap.get(pd.Contact__c);
            if(delegatedParticipants == null) delegatedParticipants = new Set<Id>();
            delegatedParticipants.add(pd.Participant__c);
            delegatedParticipantsMap.put(pd.Contact__c, delegatedParticipants);
            allDelegatedParticipantIds.add(pd.Participant__c);
        }
        
        List<Participant_Enrollment__c> peList = [
                SELECT Id,
                        Participant__c,
                        Participant_Contact__c,
                        Clinical_Trial_Profile__r.Community_Template__c
                FROM Participant_Enrollment__c
                WHERE Participant__c IN: allDelegatedParticipantIds OR Participant_Contact__c IN: contactIds
        ];
        Map<Id, Set<String>> participantPermissions = new Map<Id, Set<String>>();
        Map<Id, Id> participantIdByContactIdMap = new Map<Id, Id>();
        for(Participant_Enrollment__c pe : peList){
            if(pe.Participant_Contact__c != null && pe.Participant__c != null) participantIdByContactIdMap.put(pe.Participant_Contact__c, pe.Participant__c);
            Set<String> permissions = participantPermissions.get(pe.Participant__c);
            if (permissions == null) permissions = new Set<String>();
            permissions.add(CommunityTemplateService.getTemplate(pe.Clinical_Trial_Profile__r.Community_Template__c).permissionSet);
            participantPermissions.put(pe.Participant__c, permissions);
        }
        
        for(Id contactId : contactIds){
            Set<String> communityPermissionSets = CommunityTemplateService.getAllPermissionSets();
            //first delete all community permission sets for delegate:
            actionAssignContactPermissions.deletePermissions(contactId, communityPermissionSets);
            //assign own permission sets:
            Id ownParticipantId = participantIdByContactIdMap.get(contactId);
            Set<String> ownPermissions;
            if(ownParticipantId != null) ownPermissions = participantPermissions.get(ownParticipantId);
            if(ownPermissions != null) actionAssignContactPermissions.addPermissions(contactId, ownPermissions);
            //assign all permission sets from available participants:
            Set<Id> participantIds = delegatedParticipantsMap.get(contactId);
            if(participantIds != null && !participantPermissions.isEmpty()){
                for(Id participantId : participantIds){
                    if (participantPermissions.containsKey(participantId)) {
                        for (String participantPermissionSet : participantPermissions.get(participantId)) {
                            if (communityPermissionSets.contains(participantPermissionSet)) {
                                actionAssignContactPermissions.addPermission(contactId, participantPermissionSet);
                            }
                        }
                    }
                }
            }
        }
        //add action to queue
        if(!actionAssignContactPermissions.isEmpty()) {
            ActionExecutor.executeAsync(actionAssignContactPermissions, Datetime.now());
        }
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