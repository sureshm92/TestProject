/**
 * Created by mkotenev on 3/5/2019.
 */

public without sharing class TaskEditRemote {

    public class TaskEditDataWrapper {
        @AuraEnabled public Task task;

        @AuraEnabled public List<LabelValueItem> taskTypeList = new List<LabelValueItem>{
                new LabelValueItem(Label.Task_Type_Not_Selected, 'Not Selected'),
                new LabelValueItem(Label.Task_Type_Medication, 'Medication'),
                new LabelValueItem(Label.Task_Type_Visit, 'Visit')
        };
        @AuraEnabled public List<LabelValueItem> reminderSetList = new List<LabelValueItem>{
                new LabelValueItem(Label.Email, 'Email'),
                new LabelValueItem(Label.Disabled, 'Disabled')
        };
        @AuraEnabled public List<LabelValueItem> reminderFrequencyList = new List<LabelValueItem>{
                new LabelValueItem(Label.One_day_before, 'Day_Before'),
                new LabelValueItem(Label.Complete_By_Date, 'By_Date')
        };

        @AuraEnabled public Boolean notReferral;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Boolean reminderEnabled;
        @AuraEnabled public Boolean createdByAdmin;

        public TaskEditDataWrapper() {
            List<Contact> delegates = PatientDelegateService.getInstance().getDelegates();
            Boolean emailPreferencesIsOn = checkEmailPreferencesIsOn();
            notReferral = ParticipantService.getInstance().getState().value != ParticipantService.ParticipantStates.REFERRAL;
            errorMessage = checkEmailPermissions(emailPreferencesIsOn, delegates);
            reminderEnabled = emailEnabledForOneRelatedContact(emailPreferencesIsOn, delegates);
            createdByAdmin = false;

            task = new Task();
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
    public static void upsertTask(String paramTask) {
        try {
            Task taskToUpsert = (Task) JSON.deserialize(paramTask, Task.class);
            taskToUpsert.OwnerId = PatientDelegateService.getInstance().getParticipantUserId();
            if(ParticipantService.getInstance().getState().isDelegate) {
                taskToUpsert.Originator__c = 'Delegate';
            } else {
                taskToUpsert.Originator__c = 'Participant';
            }
            if (taskToUpsert.Visible_For__c == null) {
                taskToUpsert.Visible_For__c = 'Owner;Delegates';
            }
            if(taskToUpsert.Task_Type__c == 'Medication' || taskToUpsert.Task_Type__c == 'Visit'){
                taskToUpsert.WhatId = ParticipantService.getInstance().getState().pse.Id;
            } else {
                taskToUpsert.Task_Type__c = 'Not Selected';
            }
            if (taskToUpsert.Id != null) {
                changeReminderDate(taskToUpsert);
            }
            upsert taskToUpsert;
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
        Set<Id> delegateIds = new Set<Id>(PatientDelegateService.getInstance().getDelegatedUsersIds());
        Boolean createdByDelegate = delegateIds.isEmpty() ? false : delegateIds.contains(task.CreatedById);

        Id participantId;
        if(ParticipantService.getInstance().getState().isDelegate){
            participantId = PatientDelegateService.getInstance().getParticipantUserId();
        } else {
            participantId = UserInfo.getUserId();
        }

        return (task.CreatedById != participantId && !createdByDelegate);
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
