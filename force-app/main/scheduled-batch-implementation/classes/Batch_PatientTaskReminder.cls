/**
 * Created by Igor Malyuta on 15.05.2019.
 */
 
public without sharing class Batch_PatientTaskReminder extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    OwnerId,
                    Community_Template_Name__c,
                    Subject,
                    Survey_Invitation__c,
                    Survey_Invitation__r.Participant_Enrollment__c,
                    Start_Date__c,
                    Task_Type__c,
                    ReminderDateTime,
                    Reminder_Date__c,
                    Reminder_Schedule__c,
                    Reminder_Schedule__r.First_Reminder_day__c,
                    Reminder_Schedule__r.Second_Reminder_day__c,
                    Reminder_Schedule__r.Use_Final_Template__c,
                    Visible_For__c,
                    WhatId,
                    Remind_Using_Email__c,
                    Remind_Using_SMS__c,
                    WhoId,
                    CreatedByAdmin__c
                FROM Task
                WHERE
                    ReminderDateTime <= :Datetime.now()
                    AND Is_Reminder_Sent__c = FALSE
                    AND Status IN :TaskService.TASK_STATUS_GROUP_AVAILABLE
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<SObject> tasks) {
        sendRemindersParticipantTeam(tasks);
        checkReminder(tasks);
        update tasks;
    }

    public override Type getType() {
        return Batch_PatientTaskReminder.class;
    }

    public override String getBatchDescription() {
        return 'Sends Email Reminders about existing Tasks';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }

    private void sendRemindersParticipantTeam(List<Task> tasks) {
        List<Id> allContactsIds = new List<Id>();
        List<Id> allPeIds = new List<Id>();
        for (Task t : tasks){
            if (t.whatId?.getSObjectType().getDescribe().getName() == 'Participant_Enrollment__c')
            {
                allPeIds.add(t.whatId);
                allContactsIds.add(t.WhoId); 
            }
            else if(t.Task_Type__c == 'Survey' ){
                allPeIds.add(t.Survey_Invitation__r.Participant_Enrollment__c);
                allContactsIds.add(t.WhoId);
            }
            else{
                allContactsIds.add(t.WhoId);
            }
        }
        Map<Id, List<Id>> delConIdsByPACon = new Map<Id, List<Id>>();
        if (allPeIds.size() > 0)
        {
            delConIdsByPACon = PatientDelegateEnrollmentService.getDelegateContactIdsByPAContactIs(
                allPeIds,true
            );
        }else{
            delConIdsByPACon = PatientDelegateEnrollmentService.getDelegateContactIdsByPAContactIs(
                allContactsIds,false
            );
        }
        for (Id paKey : delConIdsByPACon.keySet())
            allContactsIds.addAll(delConIdsByPACon.get(paKey));

        Map<Id, Contact> contactsMap = new Map<Id, Contact>();
        Map<Id, List<Contact>> delegatesByPAContact = new Map<Id, List<Contact>>();
        if (allContactsIds.size() > 0) { 
            contactsMap = new Map<Id, Contact>(
                [
                    SELECT Id, Participant_Opt_In_Status_Emails__c
                    FROM Contact
                    WHERE Id IN :allContactsIds
                ]
            );
            for (Id paKey : delConIdsByPACon.keySet()) {
                List<Contact> delegateContacts = new List<Contact>();
                for (Id delId : delConIdsByPACon.get(paKey))
                    delegateContacts.add(contactsMap.get(delId));

                delegatesByPAContact.put(paKey, delegateContacts);
            }
       }

        List<Notification__c> notifications = new List<Notification__c>();
        for (Task task : tasks) {
            Contact paContact = contactsMap.get(task.WhoId);
            notifications.addAll(
                SendEmailToParticipant.createTaskReminderEmail(
                    task,
                    paContact,
                    delegatesByPAContact.get(paContact.Id)
                )
            );
        }

        if (!notifications.isEmpty())
            insert notifications;
    }

    private void checkReminder(List<Task> tasks) {
        Set<Id> contactIds = new Set<Id>();
        for (Task t : tasks)
            contactIds.add(t.WhoId);

        for (Task t : tasks) {
            t.Is_Reminder_Sent__c = true;
            if (t.Reminder_Schedule__c == null)
                continue;

            Integer secondReminder = (Integer) t.Reminder_Schedule__r.Second_Reminder_day__c;
            if (secondReminder != null) {
                Datetime startDT = Datetime.newInstance(t.Start_Date__c, t.Reminder_Date__c.time());
                Datetime reminderDate = startDT.addDays(secondReminder);

                if (t.Reminder_Date__c < reminderDate) {
                    t.Reminder_Date__c = reminderDate;
                    t.ReminderDateTime = t.ReminderDateTime.addDays(secondReminder);
                    t.Is_Reminder_Sent__c = false;
                }
            }
        }
    }
}