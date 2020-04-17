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

    public class CreateNewAssignmentNotification extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createDelegateAssignmentNotification(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------
    @TestVisible
    private static void setDefaultPatientStatus(List<Patient_Delegate__c> newList) {
        for (Patient_Delegate__c participantDelegate : newList) {
            participantDelegate.Status__c = PATIENT_DELEGATE_ACTIVE_STATUS;
        }
    }

    private static void updatePermissionSets(List<Patient_Delegate__c> changedPDList){
        Set<Id> contactIds = new Set<Id>();
        for(Patient_Delegate__c pd : changedPDList) contactIds.add(pd.Contact__c);
        PatientDelegateService.updatePermissionSets(contactIds);
    }

    @TestVisible
    private static void createDelegateAssignmentNotification(List<Patient_Delegate__c> patientDelegates) {
        List<Patient_Delegate__c> newPatientDelegates = [
                SELECT Contact__c,
                        Participant__c,
                        Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Id IN:patientDelegates
        ];

        Set<Id> participantContacts = new Set<Id>();
        Map<Id, List<Participant__c>> participantsByDelContId = new Map<Id, List<Participant__c>>();
        for (Patient_Delegate__c delegate : newPatientDelegates) {
            if(!participantsByDelContId.containsKey(delegate.Contact__c)) {
                participantsByDelContId.put(delegate.Contact__c, new List<Participant__c>());
            }
            participantsByDelContId.get(delegate.Contact__c).add(delegate.Participant__r);
            participantContacts.add(delegate.Participant__r.Contact__c);
        }

        List<PermissionSetAssignment> permissionSetAssignments = [
                SELECT
                        Assignee.ContactId,
                        PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE (Assignee.ContactId IN:participantsByDelContId.keySet() OR Assignee.ContactId IN:participantContacts)
                AND PermissionSet.Name IN:CommunityTemplateService.getAllPermissionSets()
        ];
        Map<Id, Set<String>> permissionsByContact = new Map<Id, Set<String>>();
        for(PermissionSetAssignment assignment : permissionSetAssignments) {
            if(!permissionsByContact.containsKey(assignment.Assignee.ContactId)) {
                permissionsByContact.put(assignment.Assignee.ContactId, new Set<String>());
            }
            permissionsByContact.get(assignment.Assignee.ContactId).add(assignment.PermissionSet.Name);
        }

        List<Notification__c> notifications = new List<Notification__c>();
        for(Id delCont : participantsByDelContId.keySet()) {
            if(!permissionsByContact.containsKey(delCont)) continue;

            Set<String> delPermissions = permissionsByContact.get(delCont);
            for(Participant__c participant : participantsByDelContId.get(delCont)) {
                for(String partPerm : permissionsByContact.get(participant.Contact__c)) {
                    if(delPermissions.contains(partPerm)) {
                        notifications.add(new Notification__c(
                                Notification_Type__c = CommunityTemplateService.getTemplateByPermissionSetName(partPerm).properties.get('DelNewAssignNotifType'),
                                Recipient__c = delCont,
                                WhatId__c = participant.Id
                        ));
                    }
                }
            }
        }

        if(!notifications.isEmpty()) insertNotifications(JSON.serialize(notifications));
    }

    @Future
    private static void insertNotifications(String notificationsJSON) {
        List<Notification__c> newNotifications =
                (List<Notification__c>) JSON.deserialize(notificationsJSON, List<Notification__c>.class);
        insert newNotifications;
    }
}