/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class Batch_PatientTaskReminder implements Database.Batchable<Task>, Database.Stateful {

    public static final Integer SCOPE_SIZE = 10;

    public Datetime executionTime = Datetime.now();
    public Datetime previousExecutionTime;
    public Integer intervalInMinutes;

    public Batch_PatientTaskReminder(Integer intervalInMinutes) {
        previousExecutionTime = Datetime.now().addHours(-1);
        this.intervalInMinutes = intervalInMinutes;
    }

    public Batch_PatientTaskReminder(Datetime previousExecutionTime, Integer intervalInMinutes) {
        this.previousExecutionTime = previousExecutionTime;
        this.intervalInMinutes = intervalInMinutes;
    }

    public void execute(Database.BatchableContext param1, List<Task> tasks) {
        SendEmailToParticipant.sendEmailNotificationWithDelegates(tasks);
    }

    public void finish(Database.BatchableContext param1) {
        System.scheduleBatch(new Batch_PatientTaskReminder(
                executionTime, intervalInMinutes), 'PatientTaskReminder', intervalInMinutes, SCOPE_SIZE);
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
                WHERE Reminder_Date__c > :previousExecutionTime
                AND Reminder_Date__c <= :executionTime
        ];

        System.debug('Records found: '+ tasks.size());
        System.debug('Prev time : ' + previousExecutionTime.format());
        System.debug('Exec time : ' + executionTime.format());

        return tasks;
    }

    public static void run(Integer intervalInMinutes) {
        Database.executeBatch(new Batch_PatientTaskReminder(intervalInMinutes), SCOPE_SIZE);
    }
}