/**
 * Created by Leonid Bartenev
 */

public without sharing class PSETriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class SetDefaultFieldsBeforeUpsertHandler extends TriggerHandler{
        
        public override void beforeInsert(List<SObject> newList) {
            setDefaultFieldsBeforeUpsert(newList);
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setDefaultFieldsBeforeUpsert(newList);
        }
    }
    
    public class ProcessStatusHistoryHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            processStatusHistory(newList, null);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            processStatusHistory(newList, (Map<Id, Participant_Study_Enrollment__c>)oldMap);
        }
    }
    
    public class CreateCompleteBaselineSurveyTaskHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            createCompleteBaselineSurveyTask(newList);
        }
    
    }
    
    public class DeactivateDeceasedUsersHandler extends TriggerHandler{
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            deactivateDeceasedUsers(newList, (Map<Id, Participant_Study_Enrollment__c>)oldMap);
        }
    
    }
    
    public class CreateWelcomeToStudyAlertHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            List<Alert__c> alerts = new List<Alert__c>();
            for(Participant_Study_Enrollment__c pse : (List<Participant_Study_Enrollment__c>) newList) {
                alerts.add(new Alert__c(
                        Contact__c = pse.Participant_Contact__c,
                        Alert_Code__c = 'Welcome_to_the_Study',
                        Record_ID__c = pse.Participant_Enrollment__c
                ));
                for(Contact contactDelegate : PatientDelegateService.getDelegateContacts(pse.Participant_Contact__c)) {
                    alerts.add(new Alert__c(
                            Contact__c = contactDelegate.Id,
                            Alert_Code__c = 'Welcome_to_the_Study_Patient_Delegates',
                            Record_ID__c = pse.Id)
                    );
                }
            }

            insert alerts;
        }
    }

    public class SendDropOutEmailHandler extends TriggerHandler{

        protected override void onAfterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendDropEmails((List<Participant_Study_Enrollment__c>) newList, (Map<Id, Participant_Study_Enrollment__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void setDefaultFieldsBeforeUpsert(List<Participant_Study_Enrollment__c> newList){
        Set<Id> ssIds = new Set<Id>();
        Set<Id> participantIds = new Set<Id>();
        for (Participant_Study_Enrollment__c pse : newList){
            ssIds.add(pse.Study_Site__c);
            participantIds.add(pse.Participant__c);
        }
        Map<Id, Study_Site__c> studySitesMap = new Map<Id, Study_Site__c>([
                SELECT Id, Principal_Investigator__c FROM Study_Site__c WHERE Id IN: ssIds
        ]);
        Map<Id, Participant__c> participantsMap = new Map<Id, Participant__c>([
                SELECT Id, Contact__c FROM Participant__c WHERE Id IN: participantIds
        ]);
        for (Participant_Study_Enrollment__c pse :newList){
            pse.PI_Contact__c = null;
            pse.Participant_Contact__c = null;
            if(pse.Study_Site__c != null) pse.PI_Contact__c = studySitesMap.get(pse.Study_Site__c).Principal_Investigator__c;
            if(pse.Participant__c != null) {
                pse.Participant_Contact__c = participantsMap.get(pse.Participant__c).Contact__c;
            }
        }
    }
    
    @TestVisible
    private static void processStatusHistory(List<Participant_Study_Enrollment__c> newList, Map<Id, Participant_Study_Enrollment__c> oldMap){
        List<PSE_Status_History__c> pseStatusHistories = new List<PSE_Status_History__c>();
        for(Participant_Study_Enrollment__c pse : newList){
            if(oldMap == null || (oldMap != null && pse.Status__c != oldMap.get(pse.Id).Status__c)){
                if(pse.Status__c == PSEService.PSE_STATUS_ENROLLED){
                    pseStatusHistories.add(new PSE_Status_History__c(
                            PSE__c = pse.Id,
                            Status__c = pse.Status__c,
                            Changed_Date__c = Datetime.now()
                    ));
                }
            }
        }
        if(pseStatusHistories.size() > 0) insert pseStatusHistories;
    }
    
    @TestVisible
    private static void createCompleteBaselineSurveyTask(List<Participant_Study_Enrollment__c> newList){
        List<User> users = [
                SELECT Id, ContactId
                FROM User
                WHERE ContactId IN (
                        SELECT Participant_Contact__c
                        FROM Participant_Study_Enrollment__c
                        WHERE Id IN: newList)
        ];

        Map<Id, Id> idsToUsers = new Map<Id, Id>();
        for(User taskOwner : users) idsToUsers.put(taskOwner.ContactId, taskOwner.Id);

        List<Participant_Study_Enrollment__c> pseList = [
                SELECT Id,
                        Participant_Contact__c,
                        Clinical_Trial_Profile__r.Participating_in_Patient_Portal__c,
                        Clinical_Trial_Profile__r.Survey__c
                FROM Participant_Study_Enrollment__c
                WHERE Id IN:newList
        ];
        List<Task> tasks = new List<Task>();
        for(Participant_Study_Enrollment__c pse : pseList) {
            if (pse.Clinical_Trial_Profile__r.Participating_in_Patient_Portal__c == 'Yes') {
                Id ownerId = idsToUsers.get(pse.Participant_Contact__c);
                tasks.add(TaskService.getInstance()
                        .createCompleteSurveyTask(ownerId, pse.Participant_Contact__c, pse.Clinical_Trial_Profile__r.Survey__c));
            }
        }
        insert tasks;
    }

    @TestVisible
    public static void deactivateDeceasedUsers(List<Participant_Study_Enrollment__c> newList, Map<Id, Participant_Study_Enrollment__c> oldMap) {
        List<Id> contactIds = new List<Id>();
        List<Participant_Study_Enrollment__c> pseList = [
                SELECT Id,
                        Participant__r.Contact__c,
                        Status__c
                FROM Participant_Study_Enrollment__c
                WHERE Id IN: newList
        ];
        for(Participant_Study_Enrollment__c pse : pseList) {
            if(pse.Status__c == PSEService.PSE_STATUS_DECEASED && pse.Status__c != oldMap.get(pse.Id).Status__c) {
                contactIds.add(pse.Participant__r.Contact__c);
            }
        }
        if(!contactIds.isEmpty()) deactivateUsers(contactIds);
    }

    @Future
    private static void deactivateUsers(List<Id> contactIds) {
        List<User> users = [
                SELECT Id, IsActive, ContactId
                FROM User
                WHERE ContactId IN :contactIds
        ];
        for(User u : users) u.IsActive = false;
        update users;
    }

    @TestVisible
    private static void sendDropEmails(
            List<Participant_Study_Enrollment__c> newList,
            Map<Id, Participant_Study_Enrollment__c> oldMap
    ) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        for(Participant_Study_Enrollment__c pse : newList) {
            if(pse.Status__c != oldMap.get(pse.Id).Status__c &&
                    pse.Status__c == PSEService.PSE_STATUS_DROP_OUT) {
                messages.add(SendEmailTemplate.createEmail('Patient_dropped_out', pse.Participant_Contact__c, pse.Id));
            }
        }

        SendEmailTemplate.sendEmailMessages(messages);
    }
}