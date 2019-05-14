/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_SendEmailToParticipant {
    
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        Task task = new Task(
                Reminder_Date__c = Datetime.now(),
                Subject = 'Some',
                OwnerId = testData.participantUser.Id
        );
        insert task;
        SendEmailToParticipant.sendEmailNotificationWithDelegates(new List<Task>{task});
        task = new Task(
                Reminder_Date__c = Datetime.now(),
                Subject = 'Some',
                OwnerId = testData.participantUser.Id,
                Task_Type__c = 'Visit',
                WhatId = testData.pse.Id
        );
        SendEmailToParticipant.sendEmailNotificationWithDelegates(new List<Task>{task});
        Test.stopTest();
    }
}