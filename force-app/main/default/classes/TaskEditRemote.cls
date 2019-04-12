/**
 * Created by mkotenev on 3/5/2019.
 */

public without sharing class TaskEditRemote {

    public class TaskEditDataWrapper {
        @AuraEnabled public Task task {get;set;}
        @AuraEnabled public List<String> taskTypeList {get;set;}
        @AuraEnabled public Boolean isReferral {get;set;}
        @AuraEnabled public String errorMessage {get;set;}
        @AuraEnabled public Boolean reminderEnabled {get;set;}

        public TaskEditDataWrapper(){
            task = new Task();
            List<Contact> delegates = PatientDelegateService.getInstance().getDelegates();
            Boolean emailPreferencesIsOn = checkEmailPreferencesIsOn();
            taskTypeList = getTaskTypeList();
            isReferral = ParticipantService.getInstance().getState().value == ParticipantService.ParticipantStates.REFERRAL;
            errorMessage = checkEmailPermissions(emailPreferencesIsOn, delegates);
            reminderEnabled = emailEnabledForOneRelatedContact(emailPreferencesIsOn, delegates);
        }
    }

    @AuraEnabled
    public static TaskEditDataWrapper getTaskEditData(Id taskId){
        TaskEditDataWrapper wrapper = new TaskEditDataWrapper();
        if(taskId != null) wrapper.task = TaskService.getTask(taskId);
        return wrapper;
    }

    @AuraEnabled
    public static String upsertTask(Task paramTask) {
        try{
            Boolean isDelegate = ParticipantService.getParticipantState().isDelegate;
            if(isDelegate){
                paramTask.OwnerId = PatientDelegateService.getInstance().getParticipantUserId();
            } else{
                paramTask.OwnerId = UserInfo.getUserId();
            }
            if (paramTask.Visible_For__c == null) {
                paramTask.Visible_For__c = 'Owner;Delegates';
            }
            if(paramTask.Task_Type__c == 'Medication' && paramTask.Task_Type__c == 'Visit'){
                paramTask.WhatId = ParticipantService.getParticipantState().pse.Id;
            }
            upsert paramTask;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return 'Success';
    }

    @AuraEnabled
    public static String deleteTask(Task paramTask) {
        try {
            delete paramTask;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return 'Success';
    }

    @AuraEnabled
    public static String markAsCompleted(Task paramTask) {
        try {
            paramTask.Status = 'Completed';
            paramTask.Completed_Date__c = Datetime.now();
            upsert paramTask;

        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return 'Success';
    }

    private static Boolean checkEmailPreferencesIsOn() {
        return PatientDelegateService.getInstance().getParticipant().Contact__r.Participant_Opt_In_Status_Emails__c;
    }

    private static List<String> getTaskTypeList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Task.Task_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListValue : picklistEntry){
            pickListValuesList.add(pickListValue.getLabel());
        }
        return pickListValuesList;
    }

    private static String checkEmailPermissions(Boolean emailPreferencesIsOn, List<Contact> delegates){
        String errorMessage = '';
        if(!emailEnabledForAllRelatedContacts(emailPreferencesIsOn, delegates)){
            errorMessage = Label.Task_Reminders_Missing;
        }
        if(!emailEnabledForCurrentContact()){
            errorMessage = Label.EmailPreferencesIsOff;
        }
        return errorMessage;
    }

    private static Boolean emailEnabledForAllRelatedContacts(Boolean emailPreferencesIsOn, List<Contact> delegates){
        if(!emailPreferencesIsOn)
            return false;
        for(Contact delegate : delegates){
            if(!delegate.Participant_Opt_In_Status_Emails__c) return false;
        }
        return true;
    }
    private static Boolean emailEnabledForOneRelatedContact(Boolean emailPreferencesIsOn, List<Contact> delegates){
        if(emailPreferencesIsOn)
            return true;
        for(Contact delegate : delegates) {
            if (delegate.Participant_Opt_In_Status_Emails__c) return true;
        }
        return false;
    }

    private static Boolean emailEnabledForCurrentContact(){
        List<Contact> currentContact = [
                SELECT  Participant_Opt_In_Status_Emails__c
                FROM    Contact
                WHERE   Id = :CommunityService.getInstance().getCurrentContactId()
        ];
        if(!currentContact.isEmpty())
            return currentContact[0].Participant_Opt_In_Status_Emails__c;
        return false;
    }

}