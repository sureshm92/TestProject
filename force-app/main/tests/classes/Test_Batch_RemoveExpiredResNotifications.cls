@IsTest(IsParallel=false)
public class Test_Batch_RemoveExpiredResNotifications {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void expiredNotifications() {
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.NotifyAttendees.class);
        TestData testData = new TestData();
        Resource__c vedioPtRes = new Resource__c(
            Content_Type__c = 'Video',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document',
            Expiration_Date__c = Date.today().addDays(-2)
        );
        insert vedioPtRes;

        Res_study__c resVideoStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = vedioPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resVideoStudy;
        Participant_Enrollment__c enroll = TestData.pe;
        Id conId = TestData.participant.Contact__c;
        Participant__c pt = TestData.participant;
        //DOC
        Notification__c nt1 = new Notification__c(
            Target_Record_Ids__c = resVideoStudy.Id,
            Recipient__c = conId,
            Status__c = 'In Progress',
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_VIDEO_TYPE,
            WhatId__c = enroll.Id
        );
        insert nt1;
        Send_Result__c sr1 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt1.Id
        );
        insert sr1;
        Notification__c nt2 = new Notification__c(
            Target_Record_Ids__c = vedioPtRes.Id,
            Recipient__c = conId,
            Status__c = 'In Progress',
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pt.Id
        );
        insert nt2;
        Send_Result__c sr2 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt1.Id
        );
        insert sr2;
        Batch_RemoveExpiredResourceNotifications bt = new Batch_RemoveExpiredResourceNotifications();
        Database.executeBatch(bt);
        bt.getBatchDescription();
        bt.getRecommendedIntervalMode();
        bt.getRecommendedRelaunchInterval();
    }
}