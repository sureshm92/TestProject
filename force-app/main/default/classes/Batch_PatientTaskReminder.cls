/**
 * Created by Igor Malyuta on 15.05.2019.
 */

public with sharing class Batch_PatientTaskReminder extends Batch_ScheduledAbstract{

    public void execute(Database.BatchableContext param1, List<SObject> tasks) {
        SendEmailToParticipant.sendEmailNotificationWithDelegates(tasks);
        for(Task t : (List<Task>) tasks) t.Is_Reminder_Sent__c = true;
        update tasks;
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
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

    public override Type getType() {
        return Batch_PatientTaskReminder.class;
    }

}