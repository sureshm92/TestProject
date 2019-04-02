/**
 * Created by mkotenev on 3/5/2019.
 */

public without sharing class TaskEditRemote {

    private static Task getTaskById(Id taskId) {
        try {
            return TaskService.getTask(taskId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String upsertTask(Task paramTask) {
        try{
            if (paramTask.OwnerId == null) {
                paramTask.OwnerId = Id.valueOf(UserInfo.getUserId());
            }
            upsert paramTask;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return 'Success';
    }

    @AuraEnabled
    public static String deleteTask(Task paramTask) {
        try {
            delete paramTask;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
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
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }

        return 'Success';
    }

    private static Boolean checkEmailPreferencesIsOn() {
        Boolean emailPreferencesIsOn = false;
        Contact currentContact = AccountSettingsController.getCurrentContact();
        emailPreferencesIsOn = currentContact.Participant_Opt_In_Status_Emails__c || currentContact.HCP_Opt_In_Patient_Status_Emails__c
                || currentContact.HCP_Opt_In_Study_Emails__c || currentContact.HCP_Opt_In_Referral_Status_Emails__c;
        if(!emailPreferencesIsOn){
            emailPreferencesIsOn = checkDelegatesPreferencesIsOn();
        }
        if(!emailPreferencesIsOn){
            emailPreferencesIsOn = checkDelegatesPreferencesIsOn();
        }
        return emailPreferencesIsOn;
    }

    private static Boolean checkDelegatesPreferencesIsOn(){
        List<Patient_Delegate__c> delegates = new List<Patient_Delegate__c>();
        delegates = PatientDelegateService.getPatientDelegates();
        for(Patient_Delegate__c delegate : delegates){
            if(delegate.Contact__r.Participant_Opt_In_Status_Emails__c || delegate.Contact__r.HCP_Opt_In_Patient_Status_Emails__c ||
                    delegate.Contact__r.HCP_Opt_In_Study_Emails__c || delegate.Contact__r.HCP_Opt_In_Referral_Status_Emails__c){
                return true;
            }
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

    @AuraEnabled
    public static TaskEditDataWrapper getTaskEditData(Id taskId){
        TaskEditDataWrapper wrapper = new TaskEditDataWrapper();
        if(taskId != null) {
            wrapper.task = getTaskById(taskId);
        }
        wrapper.emailPreferencesIsOn = checkEmailPreferencesIsOn();
        wrapper.taskTypeList = getTaskTypeList();
        return wrapper;
    }

    public class TaskEditDataWrapper {
        @AuraEnabled
        public Task task {get;set;}
        @AuraEnabled
        public Boolean emailPreferencesIsOn {get;set;}
        @AuraEnabled
        public List<String> taskTypeList {get;set;}

        public TaskEditDataWrapper(){
            task = new Task();
            emailPreferencesIsOn = false;
            List<String> taskTypeList = new List<String>();
        }
    }
}