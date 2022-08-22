@isTest
public class Test_SendResultService {
    @testSetup
    static void methodName() {
        TestData.loadTestData();

        Participant_Enrollment__c pe = [
            SELECT Id, Welcome_Message_Sent__c, Participant__r.Contact__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];

        Contact con = [
            SELECT Id, Welcome_Message_Sent__c
            FROM Contact
            WHERE firstname = 'PITD'
            LIMIT 1
        ];

        List<Notification__c> newList = new List<Notification__c>();
        List<Send_Result__c> sendresultnewList = new List<Send_Result__c>();

        Notification__c notifyForTest = new Notification__c(
            Notification_Type__c = 'Message_To_PT_Study_Level_Welcome_Msg',
            Recipient__c = pe.Participant__r.Contact__c,
            WhatId__c = pe.Id
        );
        newList.add(notifyForTest);

        Notification__c notifyForTest1 = new Notification__c(
            Notification_Type__c = 'Msg_To_PT_Platform_Lvl_Welcme_Msg',
            Recipient__c = pe.Participant__r.Contact__c,
            WhatId__c = pe.Participant__c
        );
        newList.add(notifyForTest1);

        insert newList;
    }
    static testMethod void Action_SendResult_Test_1() {
        Test.startTest();
        List<Notification__c> notification = [
            SELECT Id, WhatId__c, Notification_Type__c
            FROM Notification__c
            WHERE Notification_Type__c = 'Message_To_PT_Study_Level_Welcome_Msg'
            LIMIT 1
        ];
        Send_Result__c sr = new Send_Result__c();
        sr.Notification__c = notification[0].id;
        sr.Target_Type__c = 'SMS';
        sr.Msg_Id__c = '122';

        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
        	ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        
        insert sr;
         Test.stopTest();
    }
    static testMethod void Action_SendResult_Test_2() {
        List<Notification__c> notification = [
            SELECT Id, WhatId__c, Notification_Type__c
            FROM Notification__c
            WHERE Notification_Type__c = 'Msg_To_PT_Platform_Lvl_Welcme_Msg'
            LIMIT 1
        ];
        Send_Result__c sr = new Send_Result__c();
        sr.Notification__c = notification[0].id;
        sr.Target_Type__c = 'SMS';
        sr.Msg_Id__c = '1223';
        insert sr;
    }
}
