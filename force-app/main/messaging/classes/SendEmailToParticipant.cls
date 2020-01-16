/**
 * Created by Leonid Bartenev
 */

public without sharing class SendEmailToParticipant {

    public static final String EMAIL_TEMPLATE_NO_TYPE_TASK = 'Patient_Task_Reminder';
    public static final String EMAIL_TEMPLATE_NO_TYPE_TASK_DELEGATE = 'Patient_Task_Reminder_Delegate';

    public static final Map<String, String> PATIENT_EMAIL_REMINDERS_TYPE_MAP = new Map<String, String>{
            TaskService.TASK_TYPE_NOT_SELECTED => NotificationType.MESSAGE_TO_PT_TASK_REMINDER_TYPE,
            TaskService.TASK_TYPE_VISIT => NotificationType.MESSAGE_TO_PT_TASK_REMINDER_VIS_TYPE,
            TaskService.TASK_TYPE_MEDICATION => NotificationType.MESSAGE_TO_PT_TASK_REMINDER_MED_TYPE
    };

    public static final Map<String, String> PATIENT_DELEGATE_EMAIL_REMINDERS_TYPE_MAP = new Map<String, String>{
            TaskService.TASK_TYPE_NOT_SELECTED => NotificationType.MESSAGE_TO_PT_TASK_REMINDER_DEL_TYPE,
            TaskService.TASK_TYPE_VISIT => NotificationType.MESSAGE_TO_PT_TASK_REMINDER_VIS_DEL_TYPE,
            TaskService.TASK_TYPE_MEDICATION => NotificationType.MESSAGE_TO_PT_TASK_REMINDER_MED_DEL_TYPE
    };

    public static final String PATIENT_SUMMARY_DOCUMENT = 'Patient_Summary_Document';
    public static final String PATIENT_PLAIN_SUMMARY = 'Patient_Plain_Summary';
    public static final String PATIENT_LOGIN = 'Patient_Log_In_Template';
    public static final String PATIENT_CREATED_DATE = 'Patient_CreatedDate_Template';
    public static final String PATIENT_VISITS_AVAILABLE = 'Patient_Visits_Become_Availiable';

    @InvocableMethod(Label='Send Email To Participant with Delegates')
    public static void sendEmailNotificationWithDelegates(List<Task> tasks) {
        for (Task task : tasks) {
            sendEmailReminderForTask(task);
        }
    }

    public static List<Notification__c> createTaskReminderEmail(Task task, Contact paCont,
            List<Contact> delegates, Map<Id, TimeZone> timeZoneByContact
    ) {
        List<Notification__c> notifications = new List<Notification__c>();
        if (task.Task_Type__c == null) return notifications;

        String patientNotificationType = PATIENT_EMAIL_REMINDERS_TYPE_MAP.get(task.Task_Type__c);
        String delegateNotificationType = PATIENT_DELEGATE_EMAIL_REMINDERS_TYPE_MAP.get(task.Task_Type__c);
        Id whatId = task.Id;

        if (task.Task_Type__c.equals(TaskService.TASK_TYPE_SURVEY)) {
            if (task.Reminder_Schedule__c == null) return notifications;

            whatId = task.Survey_Invitation__c;
            patientNotificationType = null;

            Integer firstReminderDay = (Integer) task.Reminder_Schedule__r.First_Reminder_day__c;
            Datetime startDT = Datetime.newInstanceGmt(task.Start_Date__c, task.Reminder_Date__c.timeGmt());
            Datetime firstReminderDate = startDT;
            if (firstReminderDay > 0) {
                firstReminderDate =
                        DateTimeConverterUtil.addDaysInUserTimeZone(startDT, timeZoneByContact.get(task.WhoId), firstReminderDay);
            }

            if (task.Reminder_Date__c == firstReminderDate) {
                patientNotificationType = task.Reminder_Schedule__r.Use_Final_Template__c ?
                        NotificationType.MESSAGE_TO_PT_SURVEY_FINAL_REMINDER_TYPE :
                        NotificationType.MESSAGE_TO_PT_SURVEY_REMINDER_TYPE;
            } else {
                Integer secondReminderDay = (Integer) task.Reminder_Schedule__r.Second_Reminder_day__c;
                if (secondReminderDay != null) {
                    Datetime secondReminderDate =
                            DateTimeConverterUtil.addDaysInUserTimeZone(startDT, timeZoneByContact.get(task.WhoId), secondReminderDay);
                    if (task.Reminder_Date__c == secondReminderDate) {
                        patientNotificationType = NotificationType.MESSAGE_TO_PT_SURVEY_FINAL_REMINDER_TYPE;
                    }
                }
            }

            delegateNotificationType = patientNotificationType;
        } else if (task.Task_Type__c.equals(TaskService.TASK_TYPE_MEDICATION) || task.Task_Type__c.equals(TaskService.TASK_TYPE_VISIT)) {
            whatId = task.WhatId;
        }

        if (patientNotificationType != null) {
            notifications.add(new Notification__c(
                    Recipient__c = paCont.Id,
                    WhatId__c = whatId,
                    Notification_Type__c = patientNotificationType
            ));
        }
        if (delegateNotificationType != null) {
            if (delegates != null && !delegates.isEmpty()) {
                for (Contact delContact : delegates) {
                    notifications.add(new Notification__c(
                            Recipient__c = delContact.Id,
                            WhatId__c = whatId,
                            Notification_Type__c = delegateNotificationType
                    ));
                }
            }
        }

        return notifications;
    }

    public static void sendEmailReminderForTask(Task task) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        if (task.Task_Type__c == 'Not Selected') {
            User user = [
                    SELECT
                            Id,
                            ContactId,
                            Contact.Participant_Opt_In_Status_Emails__c
                    FROM User
                    WHERE Id = :task.OwnerId
            ];
            addContactToEmailListIfAvailable(
                    emailMessages,
                    user.Contact,
                    EMAIL_TEMPLATE_NO_TYPE_TASK,
                    task.Id
            );
            addMessagesForDelegates(
                    emailMessages,
                    PatientDelegateService.getDelegatedContactIds(user.ContactId),
                    EMAIL_TEMPLATE_NO_TYPE_TASK_DELEGATE,
                    task.Id
            );
        } else if (task.WhatId != null && task.WhatId.getSobjectType() == Participant_Enrollment__c.getSObjectType() && task.Task_Type__c != null) {
            Participant_Enrollment__c pe = [
                    SELECT
                            Id,
                            Participant__c,
                            Participant__r.Contact__c,
                            Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c
                    FROM Participant_Enrollment__c
                    WHERE Id = :task.WhatId
            ];
            addContactToEmailListIfAvailable(
                    emailMessages,
                    pe.Participant__r.Contact__r,
                    PATIENT_EMAIL_REMINDERS_TYPE_MAP.get(task.Task_Type__c),
                    task.WhatId
            );
            addMessagesForDelegates(
                    emailMessages,
                    PatientDelegateService.getDelegatedContactIds(pe.Participant__r.Contact__c),
                    PATIENT_DELEGATE_EMAIL_REMINDERS_TYPE_MAP.get(task.Task_Type__c),
                    task.WhatId
            );
        }

        SendEmailTemplate.sendEmailMessages(emailMessages);
        System.debug('EMAIL MESSAGES: ' + emailMessages.size());
    }

    private static void addContactToEmailListIfAvailable(List<Messaging.SingleEmailMessage> emailMessages, Contact patientContact, String emailTemplate, Id whatId) {
        if (patientContact.Participant_Opt_In_Status_Emails__c) {
            emailMessages.add(SendEmailTemplate.createEmail(emailTemplate, patientContact.Id, whatId));
        }
    }

    private static void addMessagesForDelegates(List<Messaging.SingleEmailMessage> emailMessages, List<Id> contactIds, String emailTemplate, Id whatId) {
        List<Contact> delegateContacts = [SELECT Id, Participant_Opt_In_Status_Emails__c FROM Contact WHERE Id IN:contactIds];
        for (Contact contact : delegateContacts) {
            if (contact.Participant_Opt_In_Status_Emails__c) emailMessages.add(SendEmailTemplate.createEmail(emailTemplate, contact.Id, whatId));
        }
    }
}
