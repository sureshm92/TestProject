/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class Batch_PatientTaskReminder implements Database.Batchable<Task>, Database.Stateful {

    public static final Integer SCOPE_SIZE = 10;
    private static final String JOB_NAME = 'PatientTaskReminder';

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        SendEmailToParticipant.sendEmailNotificationWithDelegates(tasks);
        for(Task t : tasks) t.Is_Reminder_Sent__c = true;
        update tasks;
    }

    public void finish(Database.BatchableContext param1) {
        List<Batch_Executor__mdt> batchExecutor = [
                SELECT Relaunch_Interval__c FROM Batch_Executor__mdt WHERE Job_Name__c = :JOB_NAME];
        if(!batchExecutor.isEmpty()) {
            Integer minutes = batchExecutor.get(0).Relaunch_Interval__c.intValue();
            System.scheduleBatch(
                    new Batch_PatientTaskReminder(), JOB_NAME, minutes, SCOPE_SIZE);
        }
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

    public static void run() {
        Database.executeBatch(new Batch_PatientTaskReminder(), SCOPE_SIZE);
    }

    public static void stop() {
        List<CronTrigger> cronTriggers = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name =: JOB_NAME
        ];
        if(!cronTriggers.isEmpty()) {
            for(CronTrigger cronT : cronTriggers) {
                System.abortJob(cronT.Id);
            }
        }
    }
}