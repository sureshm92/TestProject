@isTest
public class Test_AutoTriggerNotificationFlow {
    @TestSetup
    static void setup() {
        TestData.loadTestData();
    }

    @isTest
    public static void testMethod1() {
        Test.startTest();
        TestData td = new TestData();
        Notification__c notObj = new Notification__c();
        notObj.Recipient__c = td.pe.Participant_Contact__c;
        notObj.Status__c = 'In Progress';
        notObj.WhatId__c=td.piContact.Id;
        // notObj.Target_Type__c='Push';
        notObj.Notification_Type__c = 'Message_To_PI_Contact_Participant_Type';
        insert notObj;
        Send_Result__c srObj = new Send_Result__c();
        srObj.Notification__c = notObj.Id;
        srObj.Status__c = 'In Progress';
        // srObj.Target_Type__c='Push';
        srObj.Notification_Type__c = 'Message_To_PI_Contact_Participant_Type';
        insert srObj;
        Test.stopTest();

    }

    @isTest
    public static void testMethod2() {
        Test.startTest();
        TestData td = new TestData();
        Notification__c notObj = new Notification__c();
        notObj.Recipient__c = td.pe.Participant_Contact__c;
        notObj.Status__c = 'In Progress';
        notObj.WhatId__c = td.pe.Id;
        //notObj.Target_Type__c='Push';
        notObj.Notification_Type__c = 'Message_to_PT_StdDoc_Certificate_Type';
        insert notObj;
        Send_Result__c srObj = new Send_Result__c();
        srObj.Notification__c = notObj.Id;
        srObj.Status__c = 'In Progress';
        //  srObj.Target_Type__c='Push';
        srObj.Notification_Type__c = 'Message_to_PT_StdDoc_Certificate_Type';
        insert srObj;
        Test.stopTest();

    }

    @isTest
    public static void testMethod3() {
        Test.startTest();
        TestData td = new TestData();
        Notification__c notObj = new Notification__c();
        notObj.Recipient__c = td.pe.Participant_Contact__c;
        notObj.Status__c = 'In Progress';
        notObj.WhatId__c = td.pe.Id;
        //notObj.Target_Type__c='Push';
        notObj.Notification_Type__c = 'Message_to_PT_has_not_Logged_In_Type';
        insert notObj;
        Send_Result__c srObj = new Send_Result__c();
        srObj.Notification__c = notObj.Id;
        srObj.Status__c = 'In Progress';
        //  srObj.Target_Type__c='Push';
        srObj.Notification_Type__c = 'Message_to_PT_has_not_Logged_In_Type';
        insert srObj;
        Test.stopTest();
    }
    @isTest
    public static void testMethod4() {
        Test.startTest();
        TestData td = new TestData();
        Task task = new Task(
            Subject = 'Other',
            Priority = 'Normal',
            Status = 'Open',
            OwnerId = Id.valueOf(UserInfo.getUserId()),
            WhatId = td.participant.Id
        );

        insert task;
        Notification__c notObj = new Notification__c();
        notObj.Recipient__c = td.pe.Participant_Contact__c;
        notObj.Status__c = 'In Progress';
        notObj.WhatId__c = task.Id;
        //notObj.Target_Type__c='Push';
        notObj.Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type';
        insert notObj;
        Send_Result__c srObj = new Send_Result__c();
        srObj.Notification__c = notObj.Id;
        srObj.Status__c = 'In Progress';
        //  srObj.Target_Type__c='Push';
        srObj.Notification_Type__c = 'Message_To_PT_Task_Reminder_Vis_Type';
        insert srObj;
        Test.stopTest();
    }
    @isTest
    public static void testMethod5() {
        Test.startTest();
        TestData td = new TestData();
        Notification__c notObj = new Notification__c();
        notObj.Recipient__c = td.pe.Participant_Contact__c;
        notObj.Status__c = 'In Progress';
        notObj.WhatId__c = td.pe.Id;
        //notObj.Target_Type__c='Push';
        notObj.Notification_Type__c = 'Message_to_PT_Data_Available_Type';
        insert notObj;
        Send_Result__c srObj = new Send_Result__c();
        srObj.Notification__c = notObj.Id;
        srObj.Status__c = 'In Progress';
        //  srObj.Target_Type__c='Push';
        srObj.Notification_Type__c = 'Message_to_PT_Data_Available_Type';
        insert srObj;
        Test.stopTest();

    }
}