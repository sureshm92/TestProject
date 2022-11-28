/**
 * Created by Leonid Bartenev
 */

public without sharing class SendEmailToParticipant {
    public static final Map<String, String> PATIENT_EMAIL_REMINDERS_TYPE_MAP = new Map<String, String>{
        TaskService.TASK_TYPE_NOT_SELECTED => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_TYPE,
        TaskService.TASK_TYPE_VISIT => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_VIS_TYPE,
        TaskService.TASK_TYPE_MEDICATION => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_MED_TYPE,
        TaskService.TASK_TYPE_ECOA => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_TYPE_ECOA

    };

    public static final Map<String, String> PATIENT_DELEGATE_EMAIL_REMINDERS_TYPE_MAP = new Map<String, String>{
        TaskService.TASK_TYPE_NOT_SELECTED => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_DEL_TYPE,
        TaskService.TASK_TYPE_VISIT => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_VIS_DEL_TYPE,
        TaskService.TASK_TYPE_MEDICATION => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_MED_DEL_TYPE,
        TaskService.TASK_TYPE_ECOA => NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_DEL_TYPE_ECOA
    };
    public static List<Notification__c> createTaskReminderEmail(
        Task task,
        Contact paCont,
        List<Contact> delegates
    ) {
        List<Notification__c> notifications = new List<Notification__c>();
        if (task.Task_Type__c == null)
            return notifications;

        String patientNotificationType = PATIENT_EMAIL_REMINDERS_TYPE_MAP.get(task.Task_Type__c);
        String delegateNotificationType = PATIENT_DELEGATE_EMAIL_REMINDERS_TYPE_MAP.get(
            task.Task_Type__c
        );
        Id whatId = task.Id;
        if(task.Task_Type__c.equals(TaskService.TASK_TYPE_ECOA)){
            whatId = task.Id;
        }
        if (
            task.Task_Type__c.equals(TaskService.TASK_TYPE_SURVEY) &&
            task.Survey_Invitation__c != null
        ) {
            if (task.Reminder_Schedule__c == null && task.Reminder_Date__c != null) {
                patientNotificationType = NotificationCatalog.MESSAGE_TO_PT_SURVEY_REMINDER_TYPE;
            } else {
                patientNotificationType = getNotificationTypeForSurvey(task);
            }
            whatId = task.Survey_Invitation__c;
            delegateNotificationType = patientNotificationType;
        }
        if (
            task.Task_Type__c.equals(TaskService.TASK_TYPE_MEDICATION) ||
            task.Task_Type__c.equals(TaskService.TASK_TYPE_VISIT)
        ) {
            whatId = task.WhatId;
        }
        if (
            ((patientNotificationType != null) &&
            patientNotificationType.equals(
                NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_VIS_TYPE
            )) ||
            ((delegateNotificationType != null) &&
            delegateNotificationType.equals(
                NotificationCatalog.MESSAGE_TO_PT_TASK_REMINDER_VIS_DEL_TYPE
            ))
        ) {
            whatId = task.Id; // Task Id for Visit and Task Reminders
        }

        if (
            task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_OWNER) &&
            patientNotificationType != null
        ) {
            Notification__c objNotification = new Notification__c(
                Recipient__c = paCont.Id,
                WhatId__c = whatId,
                Notification_Type__c = patientNotificationType
            );
            if (
                task.Remind_Using_Email__c ||
                task.Remind_Using_SMS__c ||
                task.CreatedByAdmin__c == true
            ) {
                objNotification.Task_Id__c = task.Id;
            }
            notifications.add(objNotification);
        }
        if (
            task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES) &&
            delegateNotificationType != null
        ) {
            if (delegates != null && !delegates.isEmpty()) {
                for (Contact delContact : delegates) {
                    Notification__c objDelNotification = new Notification__c(
                        Recipient__c = delContact.Id,
                        WhatId__c = whatId,
                        IsDelegate__c = true,
                        Notification_Type__c = delegateNotificationType
                    );
                    if (
                        task.Remind_Using_Email__c ||
                        task.CreatedByAdmin__c == true ||
                        task.Remind_Using_SMS__c
                    ) {
                        objDelNotification.Task_Id__c = task.Id;
                    }
                    notifications.add(objDelNotification);
                }
            }
        }

        return notifications;
    }

    public static String getNotificationTypeForSurvey(Task task) {
        String patientNotificationType;
        Integer firstReminderDay = (Integer) task.Reminder_Schedule__r.First_Reminder_day__c;
        Datetime startDT = Datetime.newInstance(task.Start_Date__c, task.Reminder_Date__c.time());
        Datetime firstReminderDate = startDT;
        if (firstReminderDay > 0)
            firstReminderDate = startDT.addDays(firstReminderDay);

        if (task.Reminder_Date__c == firstReminderDate) {
            patientNotificationType = task.Reminder_Schedule__r.Use_Final_Template__c
                ? NotificationCatalog.MESSAGE_TO_PT_SURVEY_FINAL_REMINDER_TYPE
                : NotificationCatalog.MESSAGE_TO_PT_SURVEY_REMINDER_TYPE;
        } else {
            Integer secondReminderDay = (Integer) task.Reminder_Schedule__r.Second_Reminder_day__c;
            if (secondReminderDay != null) {
                Datetime secondReminderDate = startDT.addDays(secondReminderDay);
                if (task.Reminder_Date__c == secondReminderDate) {
                    patientNotificationType = NotificationCatalog.MESSAGE_TO_PT_SURVEY_FINAL_REMINDER_TYPE;
                }
            }
        }

        return patientNotificationType;
    }
}
