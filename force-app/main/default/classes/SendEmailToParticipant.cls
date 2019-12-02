/**
 * Created by Leonid Bartenev
 */

public without sharing class SendEmailToParticipant {

    public static final String EMAIL_TEMPLATE_NO_TYPE_TASK = 'Patient_Task_Reminder';
    public static final String EMAIL_TEMPLATE_NO_TYPE_TASK_DELEGATE = 'Patient_Task_Reminder_Delegate';

    public static final String EMAIL_TEMPLATE_MEDICATION_TASK = 'Patient_Task_Reminder_Medication';
    public static final String EMAIL_TEMPLATE_MEDICATION_TASK_DELEGATE = 'Patient_Task_Reminder_Medication_Del';

    public static final String EMAIL_TEMPLATE_VISIT_TASK = 'Patient_Task_Reminder_Visit';
    public static final String EMAIL_TEMPLATE_VISIT_TASK_DELEGATE = 'Patient_Task_Reminder_Visit_Del';

    public static final String EMAIL_TEMPLATE_SURVEY_REMINDER_TASK = 'Patient_Survey_Reminder';
    public static final String EMAIL_TEMPLATE_SURVEY_FINAL_REMINDER_TASK = 'Patient_Survey_Final_Reminder';

    public static final Map<String, String> PATIENT_EMAIL_REMINDERS_TEMPLATES_MAP = new Map<String, String>{
            TaskService.TASK_TYPE_VISIT => EMAIL_TEMPLATE_VISIT_TASK,
            TaskService.TASK_TYPE_MEDICATION => EMAIL_TEMPLATE_MEDICATION_TASK,
            TaskService.TASK_TYPE_SURVEY => EMAIL_TEMPLATE_SURVEY_REMINDER_TASK
    };

    public static final Map<String, String> PATIENT_DELEGATE_EMAIL_REMINDERS_TEMPLATES_MAP = new Map<String, String>{
            TaskService.TASK_TYPE_VISIT => EMAIL_TEMPLATE_VISIT_TASK_DELEGATE,
            TaskService.TASK_TYPE_MEDICATION => EMAIL_TEMPLATE_MEDICATION_TASK_DELEGATE
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
            addPatientToEmailListIfAvailable(
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

        } else if (task.Task_Type__c == TaskService.TASK_TYPE_SURVEY) {
            emailMessages.addAll(sendEmailSurveyNotification(task));
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
            addPatientToEmailListIfAvailable(
                    emailMessages,
                    pe.Participant__r.Contact__r,
                    PATIENT_EMAIL_REMINDERS_TEMPLATES_MAP.get(task.Task_Type__c),
                    task.WhatId
            );
            addMessagesForDelegates(
                    emailMessages,
                    PatientDelegateService.getDelegatedContactIds(pe.Participant__r.Contact__c),
                    PATIENT_DELEGATE_EMAIL_REMINDERS_TEMPLATES_MAP.get(task.Task_Type__c),
                    task.WhatId
            );
        }

        SendEmailTemplate.sendEmailMessages(emailMessages);
        System.debug('EMAIL MESSAGES: ' + emailMessages.size());
    }

    public static List<Messaging.SingleEmailMessage> sendEmailSurveyNotification(Task task) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        if (task.Reminder_Schedule__c == null) return emailMessages;

        Map<Id, Contact> contactMap = new Map<Id, Contact>([
                SELECT Id, Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Id = :task.WhoId
        ]);

        Integer firstReminderDay = (Integer) task.Reminder_Schedule__r.First_Reminder_day__c;
        Datetime startDT = Datetime.newInstanceGmt(task.Start_Date__c, task.Reminder_Date__c.timeGmt());
        Datetime firstReminderDate = startDT;
        if (firstReminderDay > 0) {
            firstReminderDate = DateTimeConverterUtil.addDaysInUserTimeZone(startDT, task.WhoId, firstReminderDay);
        }

        String template;
        if (task.Reminder_Date__c == firstReminderDate) {
            if (task.Reminder_Schedule__r.Use_Final_Template__c) {
                template = EMAIL_TEMPLATE_SURVEY_FINAL_REMINDER_TASK;
            } else {
                template = EMAIL_TEMPLATE_SURVEY_REMINDER_TASK;
            }
        } else {
            Integer secondReminderDay = (Integer) task.Reminder_Schedule__r.Second_Reminder_day__c;
            if (secondReminderDay != null) {
                Datetime secondReminderDate = DateTimeConverterUtil.addDaysInUserTimeZone(startDT, task.WhoId, secondReminderDay);
                if (task.Reminder_Date__c == secondReminderDate) {
                    template = EMAIL_TEMPLATE_SURVEY_FINAL_REMINDER_TASK;
                }
            }
        }

        if (template != null) {
            if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_OWNER)) {
                addPatientToEmailListIfAvailable(
                        emailMessages,
                        contactMap.get(task.WhoId),
                        template,
                        task.Survey_Invitation__c
                );
            }
            if (task.Visible_For__c.contains(TaskService.TASK_VISIBILITY_DELEGATES)) {
                addMessagesForDelegates(
                        emailMessages,
                        PatientDelegateService.getDelegatedContactIds(contactMap.get(task.WhoId).Id),
                        template,
                        task.Survey_Invitation__c
                );
            }
        }

        return emailMessages;
    }

    public static void sendParticipantLoginNotification(List<Contact> contacts, Boolean isOneYear) {
        String template = isOneYear ? PATIENT_CREATED_DATE : PATIENT_LOGIN;

        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Contact con : contacts) {
            addPatientToEmailListIfAvailable(
                    emailMessages,
                    con,
                    template,
                    con.Current_Participant_Enrollment__c
            );
        }

        SendEmailTemplate.sendEmailMessages(emailMessages);
    }

    public static void sendPlainSummaryNotifications(List<Contact> contacts, Map<Id, Id> peIdByContact, String nameOfEmailTemplate) {
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        for (Contact con : contacts) {
            addPatientToEmailListIfAvailable(
                    emailMessages,
                    con,
                    nameOfEmailTemplate,
                    peIdByContact.get(con.Id)
            );
        }

        SendEmailTemplate.sendEmailMessages(emailMessages);
    }

    private static void addPatientToEmailListIfAvailable(List<Messaging.SingleEmailMessage> emailMessages, Contact patientContact, String emailTemplate, Id whatId) {
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