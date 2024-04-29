@isTest
    public Class CreateNotificationTimezoneFlowTest{
    @TestSetup
    static void setup() {
        TestData.loadTestData();
    }
    @isTest
    public static void testMethod1() {
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
        List<Notification__c> lstNotfction = new List<Notification__c>();
        Notification__c notObj1 = new Notification__c(
        Recipient__c = td.pe.Participant_Contact__c,
        IsDelegate__c = true,
        WhatId__c=task.Id,
        Notification_Type__c = 'Message_To_PT_Task_Instant_Type'
        );
        lstNotfction.add(notObj1);
        Long key = 15;
        Map<String, Object> params = new Map<String, Object>(); //For flow passing variables
        params.clear();
        params.put('NotificationList', lstNotfction);
        params.put('OffsetHr', key);
        //Flow.Interview.Create_Notification_based_on_User_Timezone yourFlow = new Flow.Interview.Create_Notification_based_on_User_Timezone(params);
        //yourFlow.start();
        Test.stopTest();
    }
    }