/**
 * Created by Leonid Bartenev
 */

public class SendEmailToParticipant {
    
    public static final String EMAIL_TEMPLATE_NO_TYPE_TASK = 'Patient_Task_Reminder';
    public static final String EMAIL_TEMPLATE_NO_TYPE_TASK_DELEGATE = 'Patient_Task_Reminder_Delegate';
    public static final String EMAIL_TEMPLATE_MEDICATION_TASK = 'Patient_Task_Reminder_Medication';
    public static final String EMAIL_TEMPLATE_MEDICATION_TASK_DELEGATE = 'Patient_Task_Reminder_Medication_Del';
    public static final String EMAIL_TEMPLATE_VISIT_TASK = 'Patient_Task_Reminder_Visit';
    public static final String EMAIL_TEMPLATE_VISIT_TASK_DELEGATE = 'Patient_Task_Reminder_Visit_Del';
    
    public static final Map<String, String> PATIENT_EMAIL_TEMPLATES_MAP = new Map<String, String>{
            TaskService.TASK_TYPE_VISIT => EMAIL_TEMPLATE_VISIT_TASK,
            TaskService.TASK_TYPE_MEDICATION => EMAIL_TEMPLATE_MEDICATION_TASK
    };
    
    public static final Map<String, String> PATIENT_DELEGATE_EMAIL_TEMPLATES_MAP = new Map<String, String>{
            TaskService.TASK_TYPE_VISIT => EMAIL_TEMPLATE_VISIT_TASK_DELEGATE,
            TaskService.TASK_TYPE_MEDICATION => EMAIL_TEMPLATE_MEDICATION_TASK_DELEGATE
    };
    
    @InvocableMethod(Label='Send Email To Participant with Delegates')
    public static void sendEmailNotificationWithDelegates(List<Task> tasks){
        for(Task task : tasks){
            sendEmailReminderForTask(task);
        }
    }
    
    public static void sendEmailReminderForTask(Task task){
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        if(task.WhatId != null && task.WhatId.getSobjectType() == Participant_Study_Enrollment__c.getSObjectType() && task.Task_Type__c != null){
            System.debug('WhatId != null');
            Participant_Study_Enrollment__c pse = [
                    SELECT
                            Id,
                            Participant__c,
                            Participant__r.Contact__c,
                            Participant__r.Contact__r.Participant_Opt_In_Status_Emails__c
                    FROM Participant_Study_Enrollment__c
                    WHERE Id =: task.WhatId
            ];
            addPatientToEmailListIfAvailable(
                    emailMessages,
                    pse.Participant__r.Contact__r,
                    PATIENT_EMAIL_TEMPLATES_MAP.get(task.Task_Type__c),
                    task.WhatId
            );
            addMessagesForDelegates(
                    emailMessages,
                    PatientDelegateService.getDelegatedContactIds(pse.Participant__r.Contact__c),
                    PATIENT_DELEGATE_EMAIL_TEMPLATES_MAP.get(task.Task_Type__c),
                    task.WhatId
            );
        }
        
        if(task.Task_Type__c == null || task.Task_Type__c == 'Not Selected'){
            User user = [
                    SELECT
                            Id,
                            ContactId,
                            Contact.Participant_Opt_In_Status_Emails__c
                    FROM User WHERE Id =: task.OwnerId
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

        }
        SendEmailTemplate.sendEmailMessages(emailMessages);
        System.debug('EMAIL MESSAGES: ' + emailMessages.size());
    }
    
    private static void addPatientToEmailListIfAvailable(List<Messaging.SingleEmailMessage> emailMessages, Contact patientContact, String emailTemplate, Id whatId){
        if(patientContact.Participant_Opt_In_Status_Emails__c){
            emailMessages.add(SendEmailTemplate.createEmail(emailTemplate, patientContact.Id, whatId));
        }
    }
    
    private static void addMessagesForDelegates(List<Messaging.SingleEmailMessage> emailMessages, List<Id> contactIds, String emailTemplate, Id whatId){
        List<Contact> delegateContacts = [SELECT Id, Participant_Opt_In_Status_Emails__c FROM Contact WHERE Id IN: contactIds];
        for(Contact contact : delegateContacts){
            if(contact.Participant_Opt_In_Status_Emails__c) emailMessages.add(SendEmailTemplate.createEmail(emailTemplate, contact.Id, whatId));
        }
    }

}