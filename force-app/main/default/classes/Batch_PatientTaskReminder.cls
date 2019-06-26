/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public without sharing class Batch_PatientTaskReminder extends Batch_ScheduledAbstract{

    public void execute(Database.BatchableContext param1, List<SObject> tasks) {
        SendEmailToParticipant.sendEmailNotificationWithDelegates(tasks);
        checkReminder(tasks);
        update tasks;
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<Task> tasks = [
                SELECT Id,
                        Description,
                        OwnerId,
                        Subject,
                        Start_Date__c,
                        Task_Type__c,
                        Reminder_Date__c,
                        Reminder_Schedule__r.First_Reminder_day__c,
                        Reminder_Schedule__r.Second_Reminder_day__c,
                        Visible_For__c,
                        WhatId,
                        WhoId
                FROM Task
                WHERE Reminder_Date__c <=: Datetime.now() AND Is_Reminder_Sent__c = FALSE
        ];

        System.debug('Records found: '+ tasks.size());
        return tasks;
    }

    public override Type getType() {
        return Batch_PatientTaskReminder.class;
    }

    private void checkReminder(List<Task> tasks) {
        for(Task t : tasks) {
            t.Is_Reminder_Sent__c = true;
            if(t.Reminder_Schedule__c == null) continue;
            Integer secondReminder = (Integer) t.Reminder_Schedule__r.Second_Reminder_day__c;
            if(secondReminder != null) {
                Datetime reminderDate =
                        Datetime.newInstance(t.Start_Date__c.addDays(secondReminder), Time.newInstance(0, 0, 0, 0));
                if(t.Reminder_Date__c.date() < reminderDate.date()) {
                    t.Reminder_Date__c = reminderDate;
                    t.Is_Reminder_Sent__c = false;
                }
            }
        }
    }
}