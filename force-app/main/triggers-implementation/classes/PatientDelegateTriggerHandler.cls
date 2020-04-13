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
        PatientDelegateService.updatePermissionSets(contactIds);
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
        if (!users.isEmpty()) {
            update users;
        }
    }

    @TestVisible
    private static void createDelegateAssignmentNotification(List<Patient_Delegate__c> patientDelegates) {
        List<Id> participantIds = new List<Id>();
        Map<Id, List<Id>> participantsByDelContId = new Map<Id, List<Id>>();
        for (Patient_Delegate__c delegate : patientDelegates) {
            participantIds.add(delegate.Participant__c);
            if(!participantsByDelContId.containsKey(delegate.Contact__c)) {
                participantsByDelContId.put(delegate.Contact__c, new List<Id>());
            }
            participantsByDelContId.get(delegate.Contact__c).add(delegate.Participant__c);
        }

        List<Participant_Enrollment__c> enrollments = [
                SELECT Id,
                        Participant__c,
                        Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Participant_Enrollment__c
                WHERE Participant__c IN:participantIds
        ];
        Map<Id, List<Participant_Enrollment__c>> enrollmentsByParticipant = new Map<Id, List<Participant_Enrollment__c>>();
        for(Participant_Enrollment__c enrollment : enrollments) {
            if(!enrollmentsByParticipant.containsKey(enrollment.Participant__c)) {
                enrollmentsByParticipant.put(enrollment.Participant__c, new List<Participant_Enrollment__c>());
            }

            enrollmentsByParticipant.get(enrollment.Participant__c).add(enrollment);
        }

        List<User> delegateUsers = [
                SELECT Id
                FROM User
                WHERE ContactId IN:participantsByDelContId.keySet()
                AND IsActive = TRUE
        ];
        List<PermissionSetAssignment> permissionSetAssignments = [
                SELECT
                        AssigneeId,
                        Assignee.ContactId,
                        PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId IN:delegateUsers
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
            for(Id participantId : participantsByDelContId.get(delCont)) {
                Map<String, Id> peIdByParticipantPermission = new Map<String, Id>();
                for (Participant_Enrollment__c pe : enrollmentsByParticipant.get(participantId)) {
                    String pePerm = CommunityTemplateService.getTemplate(pe.Clinical_Trial_Profile__r.CommunityTemplate__c).permissionSet;
                    if (peIdByParticipantPermission.containsKey(pePerm)) continue;

                    peIdByParticipantPermission.put(pePerm, pe.Id);
                }
                for(String partPerm : peIdByParticipantPermission.keySet()) {
                    if(delPermissions.contains(partPerm)) {
                        notifications.add(new Notification__c(
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_DEL_NEW_ASSIGNMENT_TYPE,
                                Recipient__c = delCont,
                                WhatId__c = peIdByParticipantPermission.get(partPerm)
                        ));
                    }
                }
            }
        }

        if(!notifications.isEmpty()) insert notifications;
    }
}