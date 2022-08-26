/**
 * Created by Gaurav Saxena
 */
@isTest
public class Batch_ProcessNotifications_Test {
    @testSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        Participant_Enrollment__c pe = [
            SELECT Id, Participant__r.Contact__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];

        Contact con = [SELECT Id FROM Contact WHERE firstname = 'PITD' LIMIT 1];

        Task t = new Task();
        t.WhoId = con.id;
        insert t;

        List<Notification__c> newList = new List<Notification__c>();
        Notification__c notifyForTest = new Notification__c(
            Notification_Type__c = 'PP_RH_Push_Notification',
            Recipient__c = pe.Participant__r.Contact__c,
            WhatId__c = pe.Id,
            Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
        );
        newList.add(notifyForTest);

        Notification__c notifyForTest1 = new Notification__c(
            Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type',
            Recipient__c = pe.Participant__r.Contact__c,
            Task_Id__c = t.Id,
            WhatId__c = pe.Id,
            Status__c = NotificationService.NOTIFICATION_STATUS_PENDING,
            Email__c = 'test1@test.com'
        );
        newList.add(notifyForTest1);

        insert newList;
    }

    static testMethod void Test_1() {
        Test.startTest();
        List<Notification__c> notifications = [
            SELECT
                Id,
                Status__c,
                WhatId__c,
                Recipient__c,
                Notification_Type__c,
                Email__c,
                From__c,
                IsDelegate__c,
                RemindUsing__c,
                Task_Id__c,
                StartDate__c
            FROM Notification__c
        ];

        Batch_ProcessNotifications obj = new Batch_ProcessNotifications();
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        QL = obj.start(BC);

        //obj.execute(BC, notifications);
        obj.finish(BC);
        //DataBase.executeBatch(obj);
        obj.getBatchDescription();
        obj.getRecommendedIntervalMode();
        obj.getRecommendedRelaunchInterval();
        Test.stopTest();
    }
}
