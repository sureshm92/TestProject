/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_SendEmailToParticipant {
    
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();

        Task task = new Task(
                Reminder_Date__c = Datetime.now(),
                Subject = 'Some',
                OwnerId = testDataInstance.participantUser.Id
        );
        insert task;
        SendEmailToParticipant.sendEmailNotificationWithDelegates(new List<Task>{task});
        task = new Task(
                Reminder_Date__c = Datetime.now(),
                Subject = 'Some',
                OwnerId = testDataInstance.participantUser.Id,
                Task_Type__c = 'Visit',
                WhatId = testDataInstance.pe.Id
        );
        SendEmailToParticipant.sendEmailNotificationWithDelegates(new List<Task>{task});
        Test.stopTest();
    }
}