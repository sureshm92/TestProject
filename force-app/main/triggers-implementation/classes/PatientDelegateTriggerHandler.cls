/**
 * Created by Leonid Bartenev
 */

public without sharing class PatientDelegateTriggerHandler {
    public static final String PATIENT_DELEGATE_ACTIVE_STATUS = 'Active';
    public static final String PATIENT_DELEGATE_ONHOLD_STATUS = 'On Hold';
    public static final String PATIENT_DELEGATE_DISCONNECTED_STATUS = 'Disconnected';

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class SetDefaultPatientDelegateStatusHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            setDefaultPatientStatus(newList);
        }
    }

    public class UpdatePermissionSetAssignments extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
             List<Patient_Delegate__c> lstPd = (Patient_Delegate__c[])newList;
            List<Patient_Delegate__c> tempListPD = new List<Patient_Delegate__c> ();
            for(Patient_Delegate__c objPd : lstPd)
            {
                if(objPd.Status__c == PatientDelegateTriggerHandler.PATIENT_DELEGATE_ACTIVE_STATUS)
                {
                    tempListPD.add(objPd);
                    break;
                }
            }
            if(!tempListPD.isEmpty())
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
    
    public class CreatePrimaryDelegateForMinor extends TriggerHandler{
        public override void beforeInsert(List<SObject> newList){
            checkPrimaryDelegate(newList);
            updateDelegateParticipant(newList,Null);
        }
        
        public override void beforeDelete(List<SObject> newList){
            notDeletePrimaryDelegate(newList);
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap){
       //     updatePrimaryDelegate(newList,(Map<Id, Patient_Delegate__c>) oldMap);
       		  updateDelegateParticipant(newList,(Map<Id, Patient_Delegate__c>) oldMap);
        }
    }

    public class CreateReactivatedNotification extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createDelegateReactivatedNotification(newList, (Map<Id, Patient_Delegate__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------
    @TestVisible
    private static void setDefaultPatientStatus(List<Patient_Delegate__c> newList) {
        for (Patient_Delegate__c participantDelegate : newList) {
            if(participantDelegate.Status__c == NULL){
                participantDelegate.Status__c = PATIENT_DELEGATE_ACTIVE_STATUS;
            }
        }
    }

    private static void updatePermissionSets(List<Patient_Delegate__c> changedPDList) {
        Set<Id> contactIds = new Set<Id>();
        for (Patient_Delegate__c pd : changedPDList)
            contactIds.add(pd.Contact__c);
        System.debug('CONTACTS FOR UPDATE PERMISSIONS:' + contactIds);
        PatientDelegateService.updatePermissionSets(contactIds);
    }

    @TestVisible
    private static void createDelegateAssignmentNotification(
        List<Patient_Delegate__c> patientDelegates
    ) {
        List<Patient_Delegate__c> newPatientDelegates = [
            SELECT Contact__c, Participant__c, Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE Id IN :patientDelegates AND Status__c =:PATIENT_DELEGATE_ACTIVE_STATUS
        ];
        createNotifications(newPatientDelegates, 'DelNewAssignNotifType');
    }

    @TestVisible
    private static void createDelegateReactivatedNotification(
        List<Patient_Delegate__c> patientDelegates,
        Map<Id, Patient_Delegate__c> oldMap
    ) {
        List<Patient_Delegate__c> updatedDelegates = [
            SELECT Contact__c, Participant__c, Participant__r.Contact__c, Status__c
            FROM Patient_Delegate__c
            WHERE Id IN :patientDelegates
        ];

        List<Patient_Delegate__c> activatedDelegates = new List<Patient_Delegate__c>();
        for (Patient_Delegate__c pd : updatedDelegates) {
            if (
                pd.Status__c == PATIENT_DELEGATE_ACTIVE_STATUS &&
                oldMap.get(pd.Id).Status__c != PATIENT_DELEGATE_ACTIVE_STATUS
            ) {
                activatedDelegates.add(pd);
            }
        }

        createNotifications(activatedDelegates, 'DelReactivatedNotifType');
    }

    private static void createNotifications(
        List<Patient_Delegate__c> patientDelegates,
        String templateProperty
    ) {
        Set<Id> participantContacts = new Set<Id>();
        Map<Id, List<Participant__c>> participantsByDelContId = new Map<Id, List<Participant__c>>();
        for (Patient_Delegate__c delegate : patientDelegates) {
            if (!participantsByDelContId.containsKey(delegate.Contact__c)) {
                participantsByDelContId.put(delegate.Contact__c, new List<Participant__c>());
            }
            participantsByDelContId.get(delegate.Contact__c).add(delegate.Participant__r);
            participantContacts.add(delegate.Participant__r.Contact__c);
        }

        //For minor participants
        List<Participant_Enrollment__c> enrollments = [
            SELECT Clinical_Trial_Profile__r.CommunityTemplate__c, Participant__c
            FROM Participant_Enrollment__c
            WHERE Participant_Contact__c IN :participantContacts
        ];
        Map<Id, List<String>> communityTemplatesByParticipant = new Map<Id, List<String>>();
        for (Participant_Enrollment__c pe : enrollments) {
            if (!communityTemplatesByParticipant.containsKey(pe.Participant__c)) {
                communityTemplatesByParticipant.put(pe.Participant__c, new List<String>());
            }
            communityTemplatesByParticipant.get(pe.Participant__c)
                .add(pe.Clinical_Trial_Profile__r.CommunityTemplate__c);
        }

        List<PermissionSetAssignment> permissionSetAssignments = [
            SELECT Assignee.ContactId, PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE
                (Assignee.ContactId IN :participantsByDelContId.keySet()
                OR Assignee.ContactId IN :participantContacts)
                AND PermissionSet.Name IN :CommunityTemplateService.getAllPermissionSets()
        ];
        Map<Id, Set<String>> permissionsByContact = new Map<Id, Set<String>>();
        for (PermissionSetAssignment assignment : permissionSetAssignments) {
            if (!permissionsByContact.containsKey(assignment.Assignee.ContactId)) {
                permissionsByContact.put(assignment.Assignee.ContactId, new Set<String>());
            }
            permissionsByContact.get(assignment.Assignee.ContactId)
                .add(assignment.PermissionSet.Name);
        }

        List<Notification__c> notifications = new List<Notification__c>();
        for (Id delCont : participantsByDelContId.keySet()) {
            if (!permissionsByContact.containsKey(delCont))
                continue;

            Set<String> delPermissions = permissionsByContact.get(delCont);
            for (Participant__c participant : participantsByDelContId.get(delCont)) {
                List<CommunityTemplate> communityTemplates = new List<CommunityTemplate>();
                if (permissionsByContact.containsKey(participant.Contact__c)) {
                    for (String partPerm : permissionsByContact.get(participant.Contact__c)) {
                        communityTemplates.add(
                            CommunityTemplateService.getTemplateByPermissionSetName(partPerm)
                        );
                    }
                } else {
                    for (
                        String templateName : communityTemplatesByParticipant.get(participant.Id)
                    ) {
                        communityTemplates.add(CommunityTemplateService.getTemplate(templateName));
                    }
                }
                for (CommunityTemplate template : communityTemplates) {
                    if (delPermissions.contains(template.permissionSet)) {
                        notifications.add(
                            new Notification__c(
                                Notification_Type__c = template.properties.get(templateProperty),
                                Recipient__c = delCont,
                                WhatId__c = participant.Id
                            )
                        );
                    }
                }
            }
        }

        if (!notifications.isEmpty())
            insertNotifications(notifications);
    }

    private static void insertNotifications(List<Notification__c> notifications) {
        if (System.isFuture() || System.isBatch()) {
            insert notifications;
        } else {
            insertNotificationsAsync(JSON.serialize(notifications));
        }
    }

    @Future
    private static void insertNotificationsAsync(String notificationsJSON) {
        List<Notification__c> newNotifications = (List<Notification__c>) JSON.deserialize(
            notificationsJSON,
            List<Notification__c>.class
        );
        insert newNotifications;
    }
    
     public static void checkPrimaryDelegate (List<Patient_Delegate__c> patientDelegates){
        Map<Id, List<Patient_Delegate__c>> pdMap = new Map<Id, List<Patient_Delegate__c>>();
        List<Patient_Delegate__c> updatedList = new List<Patient_Delegate__c> ();
        Set<Id> participantIdList = new Set<Id> ();
        for(Patient_Delegate__c pd : patientDelegates){
            participantIdList.add(pd.Participant__c);
        }
        For(Participant__c pList: [SELECT Id,Adult__c,(SELECT Id,Primary_Delegate__c
                                                       FROM Participants__r)
                                   FROM Participant__c
                                   WHERE Id IN: participantIdList])
        {
            pdMap.put(pList.Id, pList.Participants__r); 
        }
        for(Id p : pdMap.keySet()){
            for(Patient_Delegate__c pdel: pdMap.get(p) ){
                for(Patient_Delegate__c pdList : patientDelegates){
                    if(pdList.Primary_Delegate__c == True && pdList.Participant__c == p){
                        pdel.Primary_Delegate__c = False;
                        updatedList.add(pdel);
                    }
                }
                /*else if(pdMap.get(p).size()==0){
                    pdList.Primary_Delegate__c = True;
                }*/
            }
        }
        update updatedList;
    }
    //Method to update the delegate particiapnt Field , REF-3858
    public static void updateDelegateParticipant(List<Patient_Delegate__c> lstpatientDelegates,
                                                 Map<Id, Patient_Delegate__c> oldMap)
    {
        List<Id> lstContactId = new List<Id> ();
        Map<Id,Id> mapDelConToDelPart = new Map<Id,Id> ();
        Map<String,Id> mapParticipantToContact = new Map<String,Id> ();
        List<Patient_Delegate__c> lstpatientDelegatesUpdated = new List<Patient_Delegate__c>();
        
        if(oldMap != Null){
            for(Patient_Delegate__c objPatientDel : lstpatientDelegates)
            {
                if(objPatientDel.Contact__c != oldMap.get(objPatientDel.Id).Contact__c)
                    lstpatientDelegatesUpdated.add(objPatientDel);
                
            }
        }
        
        if((oldMap != Null && !lstpatientDelegatesUpdated.isEmpty()) 
           || oldMap == Null) {
               for(Patient_Delegate__c objPatientDel : lstpatientDelegates)
               {
                   String strUniqueKey = objPatientDel.Participant__c + '_' + objPatientDel.Contact__c;
                   lstContactId.add(objPatientDel.Contact__c);
                   mapParticipantToContact.put(strUniqueKey, objPatientDel.Contact__c); 
               } 
               for(Participant__c objParticipant : [SELECT ID,Contact__c from participant__c Where
                                                    Contact__c IN:lstContactId])
               {
                   mapDelConToDelPart.put(objParticipant.contact__c, objParticipant.id);
                   
               }
               for(Patient_Delegate__c objPatientDel : lstpatientDelegates)
               {
                   String strUniqueKey = objPatientDel.Participant__c + '_' + objPatientDel.Contact__c;
                   objPatientDel.Participant_Delegate__c = mapDelConToDelPart.get(mapParticipantToContact.get(strUniqueKey));
               }
           } 
        
    }
    
    
    
    
    public static void notDeletePrimaryDelegate(List <Patient_Delegate__c> patientDelegates){
        for(Patient_Delegate__c pd: patientDelegates){
            if(pd.Primary_Delegate__c == True){
                pd.addError('Cannot delete Primary Delegate');
            }
        }
    }
    
    public static void updatePrimaryDelegate(
        List<Patient_Delegate__c> patientDelegates,
        Map<Id, Patient_Delegate__c> oldMap
    ){
        Map<Id, List<Patient_Delegate__c>> pdMap = new Map<Id, List<Patient_Delegate__c>>();
        List<Patient_Delegate__c> updatedList = new List<Patient_Delegate__c> ();
        List<Patient_Delegate__c> errorList = new List<Patient_Delegate__c> ();
        Set<Id> participantIdList = new Set<Id> ();
        for(Patient_Delegate__c pd : patientDelegates){
            participantIdList.add(pd.Participant__c);
        }
        For(Participant__c pList: [SELECT Id,Adult__c,(SELECT Id,Primary_Delegate__c
                                                       FROM Participants__r)
                                   FROM Participant__c
                                   WHERE Id IN: participantIdList])
        {
            pdMap.put(pList.Id, pList.Participants__r); 
        }
        for(Id p : pdMap.keySet()){
            for(Patient_Delegate__c pdList : patientDelegates){
                if(pdList.Primary_Delegate__c == True){
                    if(oldMap.get(pdList.Id).Primary_Delegate__c == False ){
                        for(Patient_Delegate__c pdel: pdMap.get(p)){
                            pdel.Primary_Delegate__c = False;
                            updatedList.add(pdel);
                        }
                        
                    }   
                }
                else{
                    if(oldMap.get(pdList.Id).Primary_Delegate__c == True ){
                        pdList.addError('Select any other primary delegate');
                        break;
                    }
                }
                if(updatedList.contains(pdList)){
                    integer a = updatedList.indexOf(pdList);
                    updatedList.remove(a);
                }
            }
        }
        if(!updatedList.isEmpty()){
            update updatedList;
        }
    }
}