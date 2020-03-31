/**
 * Created by mkotenev on 3/5/2019.
 */

public without sharing class TaskEditRemote {

    public Boolean isDelegate;

    public class TaskEditDataWrapper {
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
                new LabelValueItem(Label.Complete_By_Date, 'By_Date'),
                new LabelValueItem(Label.One_day_before, 'Day_Before')
        };

        @AuraEnabled public Task task;
        @AuraEnabled public Date today;
        @AuraEnabled public Date activityDate;
        @AuraEnabled public Date reminderDate;
        @AuraEnabled public Boolean isEnrolled;
        @AuraEnabled public String errorMessage;
        @AuraEnabled public Boolean reminderEnabled;
        @AuraEnabled public Boolean createdByAdmin;
        @AuraEnabled public Boolean isStudyTasksEnabled;

        public TaskEditDataWrapper() {
            List<Contact> delegates = PatientDelegateService.getInstance().getDelegates();
            Boolean emailPreferencesIsOn = checkEmailPreferencesIsOn();

            ParticipantService.ParticipantStates status = ParticipantService.getInstance().getState().value;
            isEnrolled = status == ParticipantService.ParticipantStates.REFERRAL ||
                    status == ParticipantService.ParticipantStates.PARTICIPANT;

            errorMessage = checkEmailPermissions(emailPreferencesIsOn, delegates);
            reminderEnabled = emailEnabledForOneRelatedContact(emailPreferencesIsOn, delegates);
            createdByAdmin = false;

            task = new Task(Task_Type__c = 'Not Selected');
            isStudyTasksEnabled = ParticipantContext.getCurrentPE() != null && ParticipantContext.getCurrentPE().Clinical_Trial_Profile__r.Tasks_Are_Available__c;
            today = Date.today();
        }
    }

    @AuraEnabled
    public static TaskEditDataWrapper getTaskEditData(Id taskId) {
        try {
            TaskEditDataWrapper wrapper = new TaskEditDataWrapper();
            if (taskId != null) {
                Task task = TaskService.getInstance().getTask(taskId);
                wrapper.task = task;

                TimeZone timezone = DateTimeConverterUtil.getUserTimeZone(CommunityService.getInstance().getCurrentContactId());
                if (task.Activity_Datetime__c != null) {
                    wrapper.activityDate = DateTimeConverterUtil.getUserDT(
                            task.Activity_Datetime__c.date(),
                            task.Activity_Datetime__c.time(),
                            timezone
                    ).date();
                }
                if (task.ReminderDateTime != null) {
                    wrapper.reminderDate = DateTimeConverterUtil.getUserDT(
                            task.ReminderDateTime.date(),
                            task.ReminderDateTime.time(),
                            timezone
                    ).date();
                }

                wrapper.createdByAdmin = createdByAdmin(task);
            }
            return wrapper;
        } catch (Exception e) {
            return (TaskEditDataWrapper) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void upsertTask(String wrapper, String paramTask) {
        try {
            TaskEditDataWrapper taskWrapper = (TaskEditDataWrapper) JSON.deserialize(wrapper, TaskEditDataWrapper.class);
            Task taskToUpsert = (Task) JSON.deserialize(paramTask, Task.class);

            taskToUpsert.Community_Template_Name__c = UserContext.getTemplateProperty(CommunityTemplateService.PROPERTY_TEMPLATE_NAME);
            taskToUpsert.OwnerId = ParticipantContext.getCurrentUserId();
            taskToUpsert.WhoId = ParticipantContext.getCurrentContactId();

            taskToUpsert.Originator__c = ParticipantContext.isCurrentDelegate() ? 'Delegate' : 'Participant';
            if (taskToUpsert.Visible_For__c == null) taskToUpsert.Visible_For__c = 'Owner;Delegates';

            if (taskToUpsert.Task_Type__c != TaskService.TASK_TYPE_NOT_SELECTED && String.isNotBlank(taskToUpsert.Task_Type__c)) {
                taskToUpsert.WhatId = ParticipantContext.getCurrentPEId();
            } else {
                taskToUpsert.WhatId = ParticipantContext.getCurrentParticipantId();
            }

            if (taskWrapper.activityDate != null) {
                taskToUpsert.Activity_Datetime__c = Datetime.newInstanceGmt(
                        taskWrapper.activityDate.year(),
                        taskWrapper.activityDate.month(),
                        taskWrapper.activityDate.day()
                );
            }
            if (taskWrapper.reminderDate != null) {
                taskToUpsert.Reminder_Date__c = taskWrapper.reminderDate;
                taskToUpsert.ReminderDateTime =
                        Datetime.newInstanceGmt(taskToUpsert.Reminder_Date__c.dateGmt(), taskToUpsert.Reminder_Date__c.timeGmt());
            }

            upsert taskToUpsert;
        } catch (Exception e) {
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
        try {
            TaskService.getInstance().ignoreTask(taskId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void markAsCompleted(Id taskId) {
        try {
            TaskService.getInstance().completeTask(taskId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    private static Boolean checkEmailPreferencesIsOn() {
        return ParticipantContext.getCurrentContact().Participant_Opt_In_Status_Emails__c;
    }

    private static String checkEmailPermissions(Boolean emailPreferencesIsOn, List<Contact> delegates) {
        String errorMessage = '';

        if (!emailEnabledForAllRelatedContacts(
                ParticipantContext.getCurrentContact().Participant_Opt_In_Status_Emails__c,
                delegates
        )) {
            errorMessage = Label.Task_Reminders_Missing;
        }
        if (!emailEnabledForCurrentContact()) {
            errorMessage = Label.EmailPreferencesIsOff;
        }
        return errorMessage;
    }

    private static Boolean emailEnabledForAllRelatedContacts(Boolean emailPreferencesIsOn, List<Contact> delegates) {
        if (!emailPreferencesIsOn) return false;
        for (Contact delegate : delegates) {
            if (!delegate.Participant_Opt_In_Status_Emails__c) return false;
        }
        return true;
    }
    private static Boolean emailEnabledForOneRelatedContact(Boolean emailPreferencesIsOn, List<Contact> delegates) {
        if (emailPreferencesIsOn) return true;
        if (ParticipantContext.isCurrentDelegate()) {
            for (Contact delegate : delegates) {
                if (delegate.Participant_Opt_In_Status_Emails__c) return true;
            }
        }
        return false;
    }

    private static Boolean emailEnabledForCurrentContact() {
        List<Contact> currentContact = [
                SELECT Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Id = :CommunityService.getInstance().getCurrentContactId()
        ];
        if (!currentContact.isEmpty()) {
            return currentContact[0].Participant_Opt_In_Status_Emails__c;
        }
        return false;
    }

    private static Boolean createdByAdmin(Task task) {
        Set<Id> delegateIds = new Set<Id>(PatientDelegateService.getInstance().getDelegatedUsersIds());
        Boolean createdByDelegate = delegateIds.isEmpty() ? false : delegateIds.contains(task.CreatedById);
        return (task.CreatedById != ParticipantContext.getCurrentUserId() && !createdByDelegate);
    }
}
