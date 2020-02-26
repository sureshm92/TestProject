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
                SELECT Id, Contact__c, Participant__r.Contact__c
                FROM Patient_Delegate__c
                WHERE Contact__c IN: contactIds AND Status__c =: PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        Map<Id, Set<Id>> delegatedContactsMap = new Map<Id, Set<Id>>();
        Set<Id> allDelegatedContactIds = new Set<Id>();
        for(Patient_Delegate__c pd : pdList){
            Set<Id> delegatedContacts = delegatedContactsMap.get(pd.Contact__c);
            if(delegatedContacts == null) delegatedContacts = new Set<Id>();
            delegatedContacts.add(pd.Participant__r.Contact__c);
            delegatedContactsMap.put(pd.Contact__c, delegatedContacts);
            allDelegatedContactIds.add(pd.Participant__r.Contact__c);
        }
        
        List<User> users = [
                SELECT Id, ContactId, (SELECT Id, PermissionSet.Name FROM PermissionSetAssignments)
                FROM User
                WHERE ContactId IN: allDelegatedContactIds
        ];
        
        Map<Id, Set<String>> delegatedContactPermissions = new Map<Id, Set<String>>();
        for(User user : users){
            Set<String> permissions = new Set<String>();
            for(PermissionSetAssignment psa : user.PermissionSetAssignments) permissions.add(psa.PermissionSet.Name);
            delegatedContactPermissions.put(user.ContactId, permissions);
        }
        
        List<Participant_Enrollment__c> peList = [
                SELECT Id,
                        Participant_Contact__c,
                        Clinical_Trial_Profile__r.Community_Template__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c IN : contactIds
        ];
        Map<Id, Set<String>> ownPermissionsMap = new Map<Id, Set<String>>();
        for(Participant_Enrollment__c pe : peList){
            Set<String> ownPermissions = ownPermissionsMap.get(pe.Participant_Contact__c);
            if(ownPermissions == null) ownPermissions = new Set<String>();
            ownPermissions.add(CommunityTemplateService.getTemplate(pe.Clinical_Trial_Profile__r.Community_Template__c).permissionSet);
            ownPermissionsMap.put(pe.Participant_Contact__c, ownPermissions);
        }
    
        for(Id contactId : contactIds){
            Set<String> communityPermissionSets = CommunityTemplateService.getAllPermissionSets();
            //first delete all community permission sets for delegate:
            actionAssignContactPermissions.deletePermissions(contactId, communityPermissionSets);
            //assign own permission sets:
            Set<String> ownPermissions = ownPermissionsMap.get(contactId);
            if(ownPermissions != null) actionAssignContactPermissions.addPermissions(contactId, ownPermissions);
            //assign all permission sets from available participants:
            Set<Id> participantContactIds = delegatedContactsMap.get(contactId);
            if(participantContactIds != null && !delegatedContactPermissions.isEmpty()){
                for(Id participantContactId : participantContactIds){
                    for(String participantPermissionSet : delegatedContactPermissions.get(participantContactId)){
                        if(communityPermissionSets.contains(participantPermissionSet)) {
                            actionAssignContactPermissions.addPermission(contactId, participantPermissionSet);
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