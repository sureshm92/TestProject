/**
 * Created by mkotenev on 3/5/2019.
 */

public without sharing class TaskEditRemote {
    
    public class TaskEditDataWrapper {
        @AuraEnabled public Task task {get;set;}
        @AuraEnabled public Boolean emailPreferencesDelegateIsOn {get;set;}
        @AuraEnabled public Boolean emailPreferencesParticipantIsOn {get;set;}
        @AuraEnabled public List<String> taskTypeList {get;set;}
        @AuraEnabled public Boolean isDelegate {get;set;}
        @AuraEnabled public Boolean hasDelegates {get;set;}
        @AuraEnabled public Boolean isReferral {get;set;}
        
        public TaskEditDataWrapper(){
            task = new Task();
            emailPreferencesDelegateIsOn = checkEmailPreferencesIsOn();
            emailPreferencesParticipantIsOn = checkDelegatesPreferencesIsOn();
            taskTypeList = getTaskTypeList();
            isDelegate = PatientDelegateService.isDelegate;
            hasDelegates = PatientDelegateService.delegates.size() > 0;
            isReferral = ParticipantService.getParticipantState().value == ParticipantService.ParticipantStates.REFERRAL;
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
                paramTask.OwnerId = PatientDelegateService.getDelegatePatientUserId();
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
        return PatientDelegateService.participant.Contact__r.Participant_Opt_In_Status_Emails__c;
    }

    private static Boolean checkDelegatesPreferencesIsOn(){
        List<Contact> delegates = new List<Contact>();
        delegates = PatientDelegateService.getDelegateContacts();
        for(Contact delegate : delegates){
            if(delegate.Participant_Opt_In_Status_Emails__c) return true;
        }
        return false;
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


}