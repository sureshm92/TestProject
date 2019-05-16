/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class Batch_PatientTaskReminder implements Database.Batchable<Task>, Database.Stateful {

    public static final Integer SCOPE_SIZE = 10;
    public Integer intervalInMinutes;

    public Batch_PatientTaskReminder(Integer intervalInMinutes) {
        this.intervalInMinutes = intervalInMinutes;
    }

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        SendEmailToParticipant.sendEmailNotificationWithDelegates(tasks);
        for(Task t : tasks) t.Is_Reminder_Sent__c = false;
        update tasks;
    }

    public void finish(Database.BatchableContext param1) {
        System.scheduleBatch(
                new Batch_PatientTaskReminder(intervalInMinutes), 'PatientTaskReminder', intervalInMinutes, SCOPE_SIZE);
    }

    public Iterable<Task> start(Database.BatchableContext param1) {
        List<Task> tasks = [
                SELECT Id,
                        OwnerId,
                        Subject,
                        Task_Type__c,
                        Reminder_Date__c,
                        WhatId,
                        WhoId
                FROM Task
                WHERE Reminder_Date__c <=: Datetime.now() AND Is_Reminder_Sent__c = FALSE
        ];

        System.debug('Records found: '+ tasks.size());
        return tasks;
    }

    public static void run(Integer intervalInMinutes) {
        Database.executeBatch(new Batch_PatientTaskReminder(intervalInMinutes), SCOPE_SIZE);
    }
}