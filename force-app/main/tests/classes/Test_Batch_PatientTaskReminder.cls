/**
 * Created by Olga Skrynnikova on 10/23/2019.
 */
@IsTest
public with sharing class Test_Batch_PatientTaskReminder {
    @IsTest
    static void testBatchExecute() {
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
        TestData.loadTestData();
        delete [SELECT Id FROM Notification__c];

        Test.startTest();
        TestData testData = new TestData();
        List<Participant__c> participant = [
                SELECT
                        Id,
                        Contact__c,
                        Contact__r.Participant_Opt_In_Status_Emails__c
                FROM Participant__c
                WHERE Id = :testData.participant.Id
        ];
        Contact c = participant.get(0).Contact__r;
        c.Participant_Opt_In_Status_Emails__c = true;
        update c;

        insert new Task(
                Subject = 'Test Name',
                Task_Type__c = 'Not Selected',
                Reminder_Date__c = Datetime.now(),
                Status = 'Open',
                ReminderDateTime = Datetime.now(),
                OwnerId = testData.participantUser.Id,
                WhoId = c.Id
        );

        List<Task> tasks = [
                SELECT Id,
                        Description,
                        OwnerId,
                        Subject,
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
                        WhoId
                FROM Task
                WHERE ReminderDateTime <= :Datetime.now()
                AND Is_Reminder_Sent__c = FALSE
                AND Status IN:TaskService.TASK_STATUS_GROUP_AVAILABLE
        ];
        new Batch_PatientTaskReminder().execute(null, tasks);
        Test.stopTest();

        List<Notification__c> notifications = [SELECT Id FROM Notification__c];
        System.assertEquals(tasks.size(), notifications.size());
    }
}