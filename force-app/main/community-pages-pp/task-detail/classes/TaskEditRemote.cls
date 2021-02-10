/**
* Created by mkotenev on 3/5/2019.
*/

public without sharing class TaskEditRemote {
    public Boolean isDelegate;
    
    public class TaskEditDataWrapper {
        @AuraEnabled
        public List<LabelValueItem> taskTypeList = new List<LabelValueItem>{
            new LabelValueItem(Label.Task_Type_Not_Selected, 'Not Selected'),
                new LabelValueItem(Label.Task_Type_Medication, 'Medication')
                //new LabelValueItem(Label.Task_Type_Visit, 'Visit')
                };
                    //@AuraEnabled public List<LabelValueItem> reminderSetList = new List<LabelValueItem>{
                    //        new LabelValueItem(Label.Email, 'Email'),
                    //        new LabelValueItem(Label.Disabled, 'Disabled')
                    //};
                    @AuraEnabled
                    public List<LabelValueItem> reminderFrequencyList = new List<LabelValueItem>{
                        new LabelValueItem(Label.PP_One_Hour_Before, '1 hour before'),
                            new LabelValueItem(Label.PP_Four_Hours_Before, '4 hours before'),
                            new LabelValueItem(Label.One_day_before, '1 day before'),
                            new LabelValueItem(Label.PP_One_Week_Before, '1 Week before'),
                            new LabelValueItem(Label.PP_Custom, 'Custom')
                            };
                                
        @AuraEnabled
        public Task task;
        @AuraEnabled
        public Datetime today;
        @AuraEnabled
        public Datetime activityDate;
        @AuraEnabled
        public Datetime reminderDate;
        @AuraEnabled
        public Boolean isEnrolled;
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public Boolean emailOptIn;
        @AuraEnabled
        public Boolean smsOptIn;
        @AuraEnabled
        public Boolean createdByAdmin;
        @AuraEnabled
        public Boolean isStudyTasksEnabled;
        @AuraEnabled
        public Datetime planDate;
        @AuraEnabled
        public String reminderOption;
        @AuraEnabled
        public String visitId;
        @AuraEnabled
        public Datetime visitDate;
        
        public TaskEditDataWrapper() {
            List<Contact> delegates = PatientDelegateService.getInstance().getDelegates();
            Boolean emailPreferencesIsOn = checkEmailPreferencesIsOn();
            Boolean smsPreferenceIsOn = checkSMSPreferencesIsOn();
            
            ParticipantService.ParticipantStates status = ParticipantService.getInstance()
                .getState()
                .value;
            isEnrolled =
                status == ParticipantService.ParticipantStates.REFERRAL ||
                status == ParticipantService.ParticipantStates.PARTICIPANT;
            
            errorMessage = checkEmailPermissions(emailPreferencesIsOn, delegates);
            emailOptIn = emailEnabledForOneRelatedContact(emailPreferencesIsOn, delegates);
            smsOptIn = smsEnabledForOneRelatedContact(smsPreferenceIsOn, delegates);
            createdByAdmin = false;
            
            task = new Task(Task_Type__c = 'Not Selected');
            isStudyTasksEnabled =
                ParticipantContext.getCurrentPE() != null &&
                ParticipantContext.getCurrentPE().Clinical_Trial_Profile__r.Tasks_Are_Available__c;
            today = Datetime.now();
        }
    }
    
    @AuraEnabled
    public static TaskEditDataWrapper getTaskEditData(Id taskId) {
        try {
            TaskEditDataWrapper wrapper = new TaskEditDataWrapper();
            if (taskId != null) {
                Task task = TaskService.getInstance().getTask(taskId);
                wrapper.task = task;
                if (task.Activity_Datetime__c != null)
                    wrapper.activityDate = task.Activity_Datetime__c;
                if (task.Reminder_Date__c != null)
                    wrapper.reminderDate = task.Reminder_Date__c;
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
            TaskEditDataWrapper taskWrapper = (TaskEditDataWrapper) JSON.deserialize(
                wrapper,
                TaskEditDataWrapper.class
            );
            Task taskToUpsert = (Task) JSON.deserialize(paramTask, Task.class);
            taskToUpsert.Community_Template_Name__c = UserContext.getTemplateProperty(
                CommunityTemplateService.PROPERTY_TEMPLATE_NAME
            );
            taskToUpsert.OwnerId = ParticipantContext.getCurrentUserId();
            taskToUpsert.WhoId = ParticipantContext.getCurrentContactId();
            if (String.isEmpty(taskToUpsert.Originator__c))
                taskToUpsert.Originator__c = ParticipantContext.isCurrentDelegate()
                ? 'Delegate'
                : 'Participant';
            if (taskToUpsert.Visible_For__c == null)
                taskToUpsert.Visible_For__c = 'Owner;Delegates';
            //Don't update WhatId for catalog and manual creation panel task
            if (String.isEmpty(taskToUpsert.Task_Code__c) && !taskWrapper.createdByAdmin) {
                if (
                    String.isNotBlank(taskToUpsert.Task_Type__c) &&
                    taskToUpsert.Task_Type__c != TaskService.TASK_TYPE_NOT_SELECTED
                ) {
                    taskToUpsert.WhatId = ParticipantContext.getCurrentPEId();
                } else {
                    taskToUpsert.WhatId = ParticipantContext.getCurrentParticipantId();
                }
            }
            //Set WhatId and Reminder_Schedule__c to NULL for Survey
            if (
                String.isNotBlank(taskToUpsert.Task_Type__c) &&
                taskToUpsert.Task_Type__c.equals(TaskService.TASK_TYPE_SURVEY)
            ) {
                taskToUpsert.WhatId = null;
                taskToUpsert.Reminder_Schedule__c = null;
            }
            //Set Task_Type__c as 'Not Selected' for COMPLETE_YOUR_PROFILE task
            if (
                String.isNotBlank(taskToUpsert.Task_Code__c) &&
                taskToUpsert.Task_Code__c.equals(TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE) &&
                String.isBlank(taskToUpsert.Task_Type__c)
            ) {
                taskToUpsert.Task_Type__c = TaskService.TASK_TYPE_NOT_SELECTED;
            }
            
            if (taskWrapper.activityDate != null && taskToUpsert.Task_Type__c != 'Visit') {
                taskToUpsert.Activity_Datetime__c = taskWrapper.activityDate;
            }
            Datetime newReminderDate;
            /*if (taskWrapper.reminderDate != null || taskWrapper.activityDate != null || taskWrapper.visitDate != null) {
                if(taskToUpsert.Task_Type__c == 'Visit'){
                    if(taskToUpsert.Remind_Me__c == '1 day before'){
                    newReminderDate = taskWrapper.visitDate.addDays(-1);
                }
                else if(taskToUpsert.Remind_Me__c == '4 hours before'){
                    newReminderDate = taskWrapper.visitDate.addHours(-4);
                }
                else if(taskToUpsert.Remind_Me__c == '1 hour before'){
                    newReminderDate = taskWrapper.visitDate.addHours(-1);
                }
                else if(taskToUpsert.Remind_Me__c == '1 Week before'){
                    newReminderDate = taskWrapper.visitDate.addDays(-7);
                }
                else{
                     newReminderDate = taskWrapper.reminderDate;
                  }
               }
               else{*/
                if(taskToUpsert.Remind_Me__c == '1 day before'){
                    newReminderDate = taskWrapper.activityDate.addDays(-1);
                }
                else if(taskToUpsert.Remind_Me__c == '4 hours before'){
                    newReminderDate = taskWrapper.activityDate.addHours(-4);
                }
                else if(taskToUpsert.Remind_Me__c == '1 hour before'){
                    newReminderDate = taskWrapper.activityDate.addHours(-1);
                }
                else if(taskToUpsert.Remind_Me__c == '1 Week before'){
                    newReminderDate = taskWrapper.activityDate.addDays(-7);
                }
                else{
                    newReminderDate = taskWrapper.reminderDate;
                }
                //}
           // }
            if(taskToUpsert.Patient_Visit__c != null){
                List<Patient_Visit__c> pv =[Select Id,Planned_Date__c from Patient_Visit__c where Id =: taskToUpsert.Patient_Visit__c LIMIT 1];
                pv[0].Planned_Date__c = taskWrapper.activityDate;
                pv[0].Status__c = 'Scheduled';
                update pv;
            }
            taskToUpsert.Reminder_Date__c = newReminderDate;
            taskToUpsert.ReminderDateTime = newReminderDate;
            upsert taskToUpsert;
            String cronTriggerId;
            if(taskToUpsert.Id != null){
               Task[] tsk =  [Select Id,CronTriggerId__c,Is_Reminder_Sent__c from Task where Id =: taskToUpsert.Id];
                if(tsk.size() >0){
                    cronTriggerId = tsk[0].CronTriggerId__c;
                }
            }
            if(!String.isEmpty(cronTriggerId)){
              System.abortJob(cronTriggerId);
             }  
            Integer seconds = 0;
            Batch_SchedulePatientTaskReminder bsptr = new Batch_SchedulePatientTaskReminder();
            String str = seconds +' '+taskToUpsert.ReminderDateTime.minute()+ ' ' + taskToUpsert.ReminderDateTime.hour()+' '+taskToUpsert.ReminderDateTime.day()+ ' '+taskToUpsert.ReminderDateTime.month()+' '+ '?'+' '+taskToUpsert.ReminderDateTime.year();
            String jobID = system.schedule(removeSpace(taskToUpsert.Subject),str, bsptr);
            taskToUpsert.CronTriggerId__c = jobID;
            taskToUpsert.Is_Reminder_Sent__c = false;
            update taskToUpsert;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void updatePatientVisits(String visit){
         try {
                Patient_Visit__c patientVisit = (Patient_Visit__c) JSON.deserialize(
                visit,
                Patient_Visit__c.class
            );
            update patientVisit;        
         } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static void upsertTaskForVisit(String wrapper, String paramTask) {
        try {
            TaskEditDataWrapper taskWrapper = (TaskEditDataWrapper) JSON.deserialize(
                wrapper,
                TaskEditDataWrapper.class
            );
            Task taskToUpsert = (Task) JSON.deserialize(paramTask, Task.class);
            Task[] existingTask;
            if(taskToUpsert.Id != null){
                existingTask =[Select Id,ReminderDateTime,CronTriggerId__c,Is_Reminder_Sent__c,Subject,OwnerId,WhoId,Visible_For__c,Originator__c,Task_Type__c,Reminder_Date__c,Remind_Me__c,WhatId,Remind_Using_Email__c,Remind_Using_SMS__c,Patient_Visit__c,Community_Template_Name__c from Task where Id =:taskToUpsert.Id AND Patient_Visit__c =: taskWrapper.visitId];
                if(existingTask.size() > 0 ){
                    taskToUpsert = existingTask[0];
                }
            }
            taskToUpsert.Community_Template_Name__c = UserContext.getTemplateProperty(
                CommunityTemplateService.PROPERTY_TEMPLATE_NAME
            );
            taskToUpsert.OwnerId = ParticipantContext.getCurrentUserId();
            taskToUpsert.WhoId = ParticipantContext.getCurrentContactId();
            
            if (String.isEmpty(taskToUpsert.Originator__c))
                taskToUpsert.Originator__c = ParticipantContext.isCurrentDelegate()
                ? 'Delegate'
                : 'Participant';
            if (taskToUpsert.Visible_For__c == null)
                taskToUpsert.Visible_For__c = 'Owner;Delegates';
            if (!taskWrapper.createdByAdmin) {
                if (String.isNotBlank(taskToUpsert.Task_Type__c) && taskToUpsert.Task_Type__c != TaskService.TASK_TYPE_NOT_SELECTED){
                    taskToUpsert.WhatId = ParticipantContext.getCurrentPEId();
                } else {
                    taskToUpsert.WhatId = ParticipantContext.getCurrentParticipantId();
                }
            }
            Datetime newReminderDate;
            //= taskToUpsert.Reminder_Date__c.addDays(-1);
            if (taskWrapper.reminderDate != null || taskWrapper.planDate !=null) {
                if(taskToUpsert.Task_Type__c == 'Visit'){
                    if(taskWrapper.reminderOption == '1 day before'){
                        newReminderDate = taskWrapper.planDate.addDays(-1);
                    }
                    else if(taskWrapper.reminderOption == '4 hours before'){
                        newReminderDate = taskWrapper.planDate.addHours(-4);
                    }
                    else if(taskWrapper.reminderOption == '1 hour before'){
                        newReminderDate = taskWrapper.planDate.addHours(-1);
                    }
                    else if(taskWrapper.reminderOption == '1 Week before'){
                        newReminderDate = taskWrapper.planDate.addDays(-7);
                    }
                    else{
                        newReminderDate = taskWrapper.reminderDate;
                    }
                    
                }
                taskToUpsert.Reminder_Date__c = newReminderDate;
                taskToUpsert.ReminderDateTime = newReminderDate;
                taskToUpsert.Remind_Me__c = taskWrapper.reminderOption;
                taskToUpsert.Remind_Using_Email__c = taskWrapper.emailOptIn;
                taskToUpsert.Remind_Using_SMS__c = taskWrapper.smsOptIn;
                taskToUpsert.Patient_Visit__c = taskWrapper.visitId;
            }
            if(taskToUpsert.Id!=null && taskToUpsert.Patient_Visit__c == taskWrapper.visitId){
                update taskToUpsert;
            }
            else{
                insert taskToUpsert;
            }
            //upsert taskToUpsert;
            if(!String.isEmpty(taskToUpsert.CronTriggerId__c)){
             System.abortJob(taskToUpsert.CronTriggerId__c);
             }
            Integer seconds = 0;
            Batch_SchedulePatientTaskReminder bsptr = new Batch_SchedulePatientTaskReminder();
            String str = seconds +' '+taskToUpsert.ReminderDateTime.minute()+ ' ' + taskToUpsert.ReminderDateTime.hour()+' '+taskToUpsert.ReminderDateTime.day()+ ' '+taskToUpsert.ReminderDateTime.month()+' '+ '?'+' '+taskToUpsert.ReminderDateTime.year();
            String jobID = system.schedule(taskToUpsert.Subject,str, bsptr);
            taskToUpsert.CronTriggerId__c = jobID;
            taskToUpsert.Is_Reminder_Sent__c = false;
            update taskToUpsert;
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
    public static String removeSpace(String str){
            String str1='';
            String[] splitString = str.split(' ');
            for(String s: splitString) {
            str1 = str1+s;
             }
        return str1;
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
    
    private static Boolean checkSMSPreferencesIsOn() {
        return ParticipantContext.getCurrentContact().Participant_Opt_In_Status_SMS__c;
    }
    
    private static String checkEmailPermissions(
        Boolean emailPreferencesIsOn,
        List<Contact> delegates
    ) {
        String errorMessage = '';
        
        if (
            !emailEnabledForAllRelatedContacts(
                ParticipantContext.getCurrentContact().Participant_Opt_In_Status_Emails__c,
                delegates
            )
        ) {
            errorMessage = Label.Task_Reminders_Missing;
        }
        if (!emailEnabledForCurrentContact()) {
            errorMessage = Label.EmailPreferencesIsOff;
        }
        return errorMessage;
    }
    
    private static Boolean emailEnabledForAllRelatedContacts(
        Boolean emailPreferencesIsOn,
        List<Contact> delegates
    ) {
        if (!emailPreferencesIsOn)
            return false;
        for (Contact delegate : delegates) {
            if (!delegate.Participant_Opt_In_Status_Emails__c)
                return false;
        }
        return true;
    }
    private static Boolean emailEnabledForOneRelatedContact(
        Boolean emailPreferencesIsOn,
        List<Contact> delegates
    ) {
        if (emailPreferencesIsOn)
            return true;
        if (ParticipantContext.isCurrentDelegate()) {
            for (Contact delegate : delegates) {
                if (delegate.Participant_Opt_In_Status_Emails__c)
                    return true;
            }
        }
        return false;
    }
    
    private static Boolean smsEnabledForOneRelatedContact(
        Boolean smsPreferencesIsOn,
        List<Contact> delegates
    ) {
        if (smsPreferencesIsOn)
            return true;
        if (ParticipantContext.isCurrentDelegate()) {
            for (Contact delegate : delegates) {
                if (delegate.Participant_Opt_In_Status_SMS__c)
                    return true;
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
        Set<Id> delegateIds = new Set<Id>(
            PatientDelegateService.getInstance().getDelegatedUsersIds()
        );
        Boolean createdByDelegate = delegateIds.isEmpty()
            ? false
            : delegateIds.contains(task.CreatedById);
        return (task.CreatedById != ParticipantContext.getCurrentUserId() && !createdByDelegate);
    }
}