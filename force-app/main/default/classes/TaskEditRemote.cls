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
        @AuraEnabled public Boolean createdByAdmin {get;set;}

        public TaskEditDataWrapper() {
            task = new Task();
            List<Contact> delegates = PatientDelegateService.getInstance().getDelegates();
            Boolean emailPreferencesIsOn = checkEmailPreferencesIsOn();
            taskTypeList = getTaskTypeList();
            isReferral = ParticipantService.getInstance().getState().value == ParticipantService.ParticipantStates.REFERRAL;
            errorMessage = checkEmailPermissions(emailPreferencesIsOn, delegates);
            reminderEnabled = emailEnabledForOneRelatedContact(emailPreferencesIsOn, delegates);
            createdByAdmin = false;
        }
    }

    @AuraEnabled
    public static TaskEditDataWrapper getTaskEditData(Id taskId) {
        TaskEditDataWrapper wrapper = new TaskEditDataWrapper();
        if (taskId != null) {
            wrapper.task = TaskService.getInstance().getTask(taskId);
            wrapper.createdByAdmin = createdByAdmin(wrapper.task);
        }
        return wrapper;
    }

    @AuraEnabled
    public static void upsertTask(Task paramTask) {
        try {
            paramTask.OwnerId = PatientDelegateService.getInstance().getParticipantUserId();
            if(ParticipantService.getInstance().getState().isDelegate) {
                paramTask.Originator__c = 'Delegate';
            } else {
                paramTask.Originator__c = 'Participant';
            }
            if (paramTask.Visible_For__c == null) {
                paramTask.Visible_For__c = 'Owner;Delegates';
            }
            if(paramTask.Task_Type__c == 'Medication' || paramTask.Task_Type__c == 'Visit'){
                paramTask.WhatId = ParticipantService.getInstance().getState().pse.Id;
            } else {
                paramTask.Task_Type__c = 'Not Selected';
            }
            if (paramTask.Id != null) {
                changeReminderDate(paramTask);
            }
            upsert paramTask;
        } catch (Exception e) {
            System.debug(e);
            AuraHelper.throwException(e);
        }
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
    public static void ignoreTask(Id taskId) {
        TasksRemote.ignoreTask(taskId);
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

    private static List<String> getTaskTypeList() {
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = Task.Task_Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntry = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListValue : picklistEntry) {
            pickListValuesList.add(pickListValue.getLabel());
        }
        return pickListValuesList;
    }

    private static String checkEmailPermissions(Boolean emailPreferencesIsOn, List<Contact> delegates) {
        String errorMessage = '';
        if (!emailEnabledForAllRelatedContacts(emailPreferencesIsOn, delegates)) {
            errorMessage = Label.Task_Reminders_Missing;
        }
        if (!emailEnabledForCurrentContact()) {
            errorMessage = Label.EmailPreferencesIsOff;
        }
        return errorMessage;
    }

    private static Boolean emailEnabledForAllRelatedContacts(Boolean emailPreferencesIsOn, List<Contact> delegates) {
        if (!emailPreferencesIsOn)
            return false;
        for (Contact delegate : delegates) {
            if (!delegate.Participant_Opt_In_Status_Emails__c) return false;
        }
        return true;
    }
    private static Boolean emailEnabledForOneRelatedContact(Boolean emailPreferencesIsOn, List<Contact> delegates) {
        if (emailPreferencesIsOn)
            return true;
        for (Contact delegate : delegates) {
            if (delegate.Participant_Opt_In_Status_Emails__c) return true;
        }
        return false;
    }

    private static Boolean emailEnabledForCurrentContact() {
        List<Contact> currentContact = [
                SELECT Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Id = :CommunityService.getInstance().getCurrentContactId()
        ];
        if (!currentContact.isEmpty())
            return currentContact[0].Participant_Opt_In_Status_Emails__c;
        return false;
    }

    private static Boolean createdByAdmin(Task task){
        Id participantId;
        Set<Id> delegateIds = new Set<Id>(PatientDelegateService.getInstance().getDelegatedUsersIds());
        if(ParticipantService.getInstance().getState().isDelegate){
            participantId = PatientDelegateService.getInstance().getParticipantUserId();
        } else {
            participantId = UserInfo.getUserId();
        }
        return (task.CreatedById != participantId && !delegateIds.contains(task.CreatedById));
    }

    private static void changeReminderDate(Task paramTask){
        Task oldTask = [
                SELECT
                        Id,
                        Reminder_Date__c
                FROM Task
                WHERE Id = :paramTask.Id
        ];
        if (paramTask.Reminder_Date__c != null && oldTask.Reminder_Date__c != paramTask.Reminder_Date__c) {
            Datetime tmpDate = paramTask.Reminder_Date__c;
            paramTask.Reminder_Date__c = null;
            upsert paramTask;
            paramTask.Reminder_Date__c = tmpDate;
        }
    }

}
