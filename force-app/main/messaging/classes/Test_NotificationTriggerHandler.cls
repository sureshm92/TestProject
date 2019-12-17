/**
 * Created by Olga Skrynnikova on 11/26/2019.
 */

@IsTest
private class Test_NotificationTriggerHandler {
    @testSetup
    static void setup() {
//        TestData.loadTestData();
//        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.SendNotificationHandler.class);
//        Participant_Enrollment__c pe = [
//                SELECT Id, Participant__r.Contact__c
//                FROM Participant_Enrollment__c
//                LIMIT 1
//        ];
//        List<Notification__c> newList = new List<Notification__c>();
//        Notification__c notifyForTest = new Notification__c(
//                Name = 'Notify Test',
//                Notification_Type__c = 'Message_to_HCP_Patient_Accepted_Type',
//                Recipient__c = pe.Participant__r.Contact__c,
//                WhatId__c = pe.Id);
//        newList.add(notifyForTest);
//        insert newList;
    }
    @IsTest
    static void checkBeforeTrigger() {
//        List<Notification__c> notifyForCheck = [SELECT Id FROM Notification__c WHERE Name = 'Notify Test'];
//        System.assertEquals(1, notifyForCheck.size());
//    }
//
//    @IsTest
//    static void checkAfterTrigger(){
//        List<Notification__c> notifyForCheck = [
//                SELECT Id,
//                        Notification_Type__c,
//                        Recipient__c, WhatId__c
//                FROM Notification__c
//                WHERE Name = 'Notify Test'];
//        Test.startTest();
//        NotificationTriggerHandler.sendNotificationToRecipient(notifyForCheck);
//        Test.stopTest();
    }

}