public without sharing class EcoaTaskService {
    public static void createTask(List<Ecoa_Task_Configuration__c> taskConfig) {
        List<Task> eTasks = new List<Task>();
        List<Id> contactIds = new List<Id>();
        Map<Id, User> userContactIdMap = new Map<Id, User>();
        Map<Id, Id> primarydelegateContactMap = new Map<Id, Id>();
        List<Ecoa_Task_Configuration__c> updatedTaskConfigList = new List<Ecoa_Task_Configuration__c>();
        System.debug('taskConfig::' + taskConfig);
        for (Ecoa_Task_Configuration__c task : taskConfig) {
            if (task.ContactId__c != null) {
                contactIds.add(task.ContactId__c);
            }
        }
        System.debug('contactIds::' + contactIds);
        List<Patient_Delegate__c> patientdelegatesList = [
            SELECT Contact__c, Participant__r.Contact__c
            FROM Patient_Delegate__c
            WHERE Participant__r.Contact__c IN :contactIds AND Primary_Delegate__c = TRUE
        ];
        for (Patient_Delegate__c pd : patientdelegatesList) {
            primarydelegateContactMap.put(pd.Participant__r.Contact__c, pd.Contact__c);
            if (!contactIds.contains(pd.Contact__c)) {
                contactIds.add(pd.Contact__c);
            }
        }
        List<User> participantUsers = [
            SELECT Id, ContactId, LocaleSidKey, TimeZoneSidKey, LanguageLocaleKey
            FROM User
            WHERE ContactId IN :contactIds
        ];
        System.debug('participantUsers' + participantUsers);
        for (User userObj : participantUsers) {
            userContactIdMap.put(userObj.ContactId, userObj);
        }
        for (Ecoa_Task_Configuration__c task : taskConfig) {
            Datetime remTime;
            if (task.Reminder_config__c != null) {
                remTime = task.Window_End__c.addHours(Integer.valueOf(-task.Reminder_config__c));
            }
            User userObj = userContactIdMap.get(task.ContactId__c);
            User delegateUserObj;
            String timeZoneVal = '';
            if (userObj != null) {
                timeZoneVal = userObj.TimeZoneSidKey;
            } else {
                Id delegatecontactId = primarydelegateContactMap.get(task.ContactId__c);
                delegateUserObj = userContactIdMap.get(delegatecontactId);
                if (delegateUserObj != null) {
                    timeZoneVal = delegateUserObj.TimeZoneSidKey;
                }
            }
            Timezone tz = Timezone.getTimeZone(timeZoneVal);
            Integer offset = tz.getOffset(task.Window_Begin__c); //-5 : 20th 5AM (UTC)

            Datetime userlocaltime = task.Window_Begin__c.addSeconds(offset / 1000); //local : 20 th12 AM
            Date userDate = date.newinstance(
                userlocaltime.year(),
                userlocaltime.month(),
                userlocaltime.day()
            );
            Datetime dt = Datetime.now();
            if (userlocaltime.day() == dt.day()) {
                userlocaltime = userlocaltime.addDays(1);
            }
            Integer endoffset = tz.getOffset(task.Window_End__c);
            Datetime WindoEndlocaltime = task.Window_End__c.addSeconds(endoffset / 1000);

            System.debug('userObj::' + userObj);
            System.debug('delegateUserObj::' + delegateUserObj);
            Task t = new Task();
            t.OwnerId = userObj != null ? userObj.Id : delegateUserObj.Id;
            t.Subject = 'eDiary ' + task.Diary_Name__c;
            t.Priority = 'Normal';
            //t.Action_URL__c ='e-diaries';
            t.Action_URL__c = 'e-diaries';
            t.Start_Date__c = date.newinstance(
                userlocaltime.year(),
                userlocaltime.month(),
                userlocaltime.day()
            ); //get date
            t.Activity_Datetime__c = task.Window_End__c;
            t.ReminderDateTime = remTime;
            t.Reminder_Date__c = remTime;
            t.Ecoa_Task_Configuration_del__c = task.Id; // ecoa config id
            t.Remind_Using_Email__c = true;
            t.Visible_For__c = TaskService.TASK_VISIBILITY_ALL;
            t.WhatId = task.ParticipantId__c; // Participant id
            t.WhoId = task.ContactId__c; // contact id
            t.Task_Type__c = TaskService.TASK_TYPE_ECOA;
            t.CreatedByAdmin__c = true;
            t.InitialTaskNotification__c = true;
            task.IsProcessed__c = true; //config
            updatedTaskConfigList.add(task);
            eTasks.add(t);
        }
        try {
            insert eTasks;
            update updatedTaskConfigList;
        } catch (exception e) {
            System.debug('error::' + e);
        }
    }
    public static void completeTask(List<Task> tasksToComplete) {
        List<Task> completedTasks = new List<Task>();
        if (tasksToComplete != null) {
            for (Task task : tasksToComplete) {
                task.Status = 'Completed';
                task.Completed_Date__c = Datetime.now();
                completedTasks.add(task);
            }
            try {
                update completedTasks;
            } catch (Exception e) {
                System.debug('err:' + e.getMessage());
                System.debug('err:' + e.getStackTraceString());
            }
        }
    }
}
