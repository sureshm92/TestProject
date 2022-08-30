/**
 * Created by Olga Skrynnikova on 10/23/2019.
 */
@IsTest
public with sharing class Test_Batch_PatientTaskReminder {
    @TestSetup
    static void setup() {
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        //Test.startTest();
        delete [SELECT Id FROM Notification__c];
        TestData testData = new TestData();
        //Test.stopTest();

        List<Participant__c> participant = [
            SELECT Id, Contact__c, Contact__r.Participant_Opt_In_Status_Emails__c
            FROM Participant__c
            WHERE Id = :testData.participant.Id
        ];
        Contact c = participant.get(0).Contact__r;
        c.Participant_Opt_In_Status_Emails__c = true;
        update c;

        Reminder_Schedule__c reminderSchedule = new Reminder_Schedule__c(
            First_Reminder_day__c = 0,
            Second_Reminder_day__c = 5
        );
        insert reminderSchedule;

        insert new Task(
            Subject = 'Test Name',
            Task_Type__c = 'Not Selected',
            Start_Date__c = Date.today(),
            Reminder_Date__c = Datetime.now(),
            Status = 'Open',
            ReminderDateTime = Datetime.now(),
            Reminder_Schedule__c = reminderSchedule.Id,
            OwnerId = testData.participantUser.Id,
            Visible_For__c = TaskService.TASK_VISIBILITY_ALL,
            WhoId = c.Id
        );
    }

    @IsTest
    static void testBatchExecute() {
        Test.startTest();
        Database.executeBatch(new Batch_PatientTaskReminder());
        Test.stopTest();

        List<Notification__c> notifications = [SELECT Id FROM Notification__c];
        System.assertEquals(1, notifications.size());
    }
}
