@IsTest(IsParallel=false)
public class Test_PPUpdatesController {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void activeParticipant(){ 
        TriggerHandlerExecutor.bypassHandler(
            TelevisitTriggerHandler.TelevisitEventTrigger.class
        );
        TriggerHandlerExecutor.bypassHandler(
            TelevisitTriggerHandler.NotifyAttendees.class
        );
        TestData testData = new TestData();
        ContentVersion contentVersion = new ContentVersion(
            LanguageCode__c = 'en_US',
            Title = 'Test Content',
            PathOnClient = 'Irregular verbs.pdf',
            VersionData = EncodingUtil.base64Decode('fdsgg5465w')
        );
        insert contentVersion;
        
        Resource__c docPtRes = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'TestRes'
        );
        insert docPtRes;
        Id docId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Test Content'
            LIMIT 1
        ]
            .ContentDocumentId;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = docPtRes.Id
        );
        insert contentDocumentLink;
        
        Res_study__c resDocStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = docPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resDocStudy;
        
        Resource__c vedioPtRes = new Resource__c(
            Content_Type__c = 'Video',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document'
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
        
        Resource__c linkPtRes = new Resource__c(
            Content_Type__c = 'Relevant_Link',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Languages__c = 'en_US',
            Type__c = 'Helpful Links',
            URL__c = 'rlev.com'
        );
        insert linkPtRes;
        
        Res_study__c resLinkStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = linkPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resLinkStudy;
        
        Participant_Enrollment__c  enroll = TestData.pe;
        Id conId = TestData.participant.Contact__c;
        Participant__c pt = TestData.participant; 
        //DOC
        Notification__c nt1 = new Notification__c(Target_Record_Ids__c=resDocStudy.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,WhatId__c=pt.Id);
        insert nt1;
        Send_Result__c sr1 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt1.Id);
        insert sr1;
        
        Notification__c nt3 = new Notification__c(Target_Record_Ids__c=docPtRes.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,WhatId__c=pt.Id);
        insert nt3;
        Send_Result__c sr3 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt3.Id);
        insert sr3;
        //VIDEO
        Notification__c nt2 = new Notification__c(Target_Record_Ids__c=vedioPtRes.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,WhatId__c=pt.Id);
        insert nt2;
        Send_Result__c sr2 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt2.Id);
        insert sr2;
        Notification__c nt4 = new Notification__c(Target_Record_Ids__c=resVideoStudy.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,WhatId__c=pt.Id);
        insert nt4;
        Send_Result__c sr4 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt4.Id);
        insert sr4;
        //Link
        
        Notification__c nt5 = new Notification__c(Target_Record_Ids__c=linkPtRes.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,WhatId__c=pt.Id);
        insert nt5;
        Send_Result__c sr5 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt5.Id);
        insert sr5;
        Notification__c nt6 = new Notification__c(Target_Record_Ids__c=resLinkStudy.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,WhatId__c=pt.Id);
        insert nt6;
        Send_Result__c sr6 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt6.Id);
        insert sr6;
        Televisit__c tv = new Televisit__c();
        tv.Title__c = 'Test Class Meet';
        tv.Duration__c = '15 minutes';
        tv.Source_Community__c = 'IQVIA Referral Hub';
        tv.Visit_Date_Time__c = Datetime.now();
        tv.Visit_End_Date_Time__c = Datetime.now().addMinutes(15);
        tv.Participant_Enrollment__c = enroll.Id;
        tv.Status__c = 'Scheduled';
        insert tv;
        Notification__c nt7 = new Notification__c(Target_Record_Ids__c=tv.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED,WhatId__c=pt.Id);
        insert nt7;
        Send_Result__c sr7 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt7.Id);
        insert sr7;
        Notification__c nt8 = new Notification__c(Target_Record_Ids__c=tv.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED,WhatId__c=pt.Id);
        insert nt8;
        Send_Result__c sr8 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt8.Id);
        insert sr8;
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        
        Visit__c visit = new Visit__c(Visit_Plan__c = vp.Id);
        insert visit;
        
        Patient_Visit__c patientVisit = new Patient_Visit__c(
            Participant_Enrollment__c = testData.pe.Id,
            Status__c = 'Completed',
            Visit__c = visit.Id,
            Visit_Number__c = 1,
            Completed_Date__c = Date.newInstance(2019, 12, 17)
        );
        insert patientVisit;
        Notification__c nt9 = new Notification__c(Target_Record_Ids__c=patientVisit.Id,Recipient__c=conId,Notification_Type__c=NotificationCatalog.UPDATE_TO_PT_NEW_VISIT_RESULT_TYPE,WhatId__c=pt.Id);
        insert nt9;
        Send_Result__c sr9 = new Send_Result__c(Target_Type__c = 'Updates',Status__c = 'In Progress',Notification__c = nt9.Id);
        insert sr9;
        System.runAs(testData.participantUser) {
            PPUpdatesController.getSendResultCount('2099-05-09 07:06:11');
            PPUpdatesController.getSendResultUpdates(0, 10, '2099-05-09 07:06:11');
            PPUpdatesController.removeUpdateCard(sr1.Id);
        }
    }  
    @isTest
    public static void delegate(){ 
        TestData testData = new TestData();
        System.runAs(testData.createPatientDelegate()) {
            PPUpdatesController.getSendResultCount('2099-05-09 07:06:11');
            PPUpdatesController.getSendResultUpdates(0, 10, '2099-05-09 07:06:11');
        }
    }   
}