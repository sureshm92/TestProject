@IsTest(IsParallel=false)
public class Test_PPUpdatesController {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void activeParticipant() {
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.NotifyAttendees.class);
        TriggerHandlerExecutor.bypassHandler(SendResultTriggerHandler.updatewelcomeMsgflagsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ResStudyTriggerHandler.PlatformEventProcessor.class);
        TriggerHandlerExecutor.bypassHandler(ResStudyTriggerHandler.CertificateResourceProcessor.class);
        TriggerHandlerExecutor.bypassHandler(ResourceTriggerHandler.ArticleResourceProcessor.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.class);
        TestData testData = new TestData();
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class);
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.manageBypassedFieldsForTMDH.class);
        TriggerHandlerExecutor.bypassHandler(CTPNotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckDuplicatesHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateParticipantAge.class);
        TriggerHandlerExecutor.bypassHandler(PatientVisitTriggerHandler.updateEcoaEvents.class);
        testData.ctp.Relevant_Links_Are_Available__c = true;
        testData.ctp.Study_Documents_Are_Available__c = true;
        testData.ctp.Video_And_Articles_Are_Available__c = true;
        update testData.ctp;
        
        Resource__c docPtRes = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'Test Res',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document',
            Version_Date__c = System.today(),
            Language__c = 'en_US',
            RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
            .get('Study_Document')
            .getRecordTypeId()
        );
        insert docPtRes;
        
        Res_study__c resDocStudy = new Res_study__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Notify_On_Availability__c = true,
            Resource__c = docPtRes.Id,
            Visible_In_Alumni__c = true,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resDocStudy;
        
        Resource__c vedioPtRes = new Resource__c(
            Content_Type__c = 'Video',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document',
            RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
            .get('Video')
            .getRecordTypeId()
        );
        insert vedioPtRes;
        
        Res_study__c resVideoStudy = new Res_study__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
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
            Type__c = 'Relevant Links',
            URL__c = 'https://www.msn.com',
            Resource_Type__c = 'Study Document',
            RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
            .get('Relevant_Link')
            .getRecordTypeId()
        );
        insert linkPtRes;
        
        Res_study__c resLinkStudy = new Res_study__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Notify_On_Availability__c = true,
            Resource__c = linkPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resLinkStudy;
        
        Participant_Enrollment__c enroll = TestData.pe;
        Id conId = TestData.participant.Contact__c;
        Participant__c pt = TestData.participant;
        Participant_Enrollment__c pe = TestData.pe;
        //DOC
        Notification__c nt1 = new Notification__c(
            Target_Record_Ids__c = resDocStudy.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pe.Id,
            Status__c = 'In Progress'
        );
        insert nt1;
        Send_Result__c sr1 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt1.Id
        );
        insert sr1;
        
        Notification__c nt3 = new Notification__c(
            Target_Record_Ids__c = docPtRes.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt3;
        Send_Result__c sr3 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt3.Id
        );
        insert sr3;
        //VIDEO
        Notification__c nt2 = new Notification__c(
            Target_Record_Ids__c = vedioPtRes.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt2;
        Send_Result__c sr2 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt2.Id
        );
        insert sr2;
        Notification__c nt4 = new Notification__c(
            Target_Record_Ids__c = resVideoStudy.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pe.Id,
            Status__c = 'In Progress'
        );
        insert nt4;
        Send_Result__c sr4 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt4.Id
        );
        insert sr4;
        //Link
        
        Notification__c nt5 = new Notification__c(
            Target_Record_Ids__c = linkPtRes.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt5;
        Send_Result__c sr5 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt5.Id
        );
        insert sr5;
        Notification__c nt6 = new Notification__c(
            Target_Record_Ids__c = resLinkStudy.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pe.Id,
            Status__c = 'In Progress'
        );
        insert nt6;
        Send_Result__c sr6 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt6.Id
        );
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
        Notification__c nt7 = new Notification__c(
            Target_Record_Ids__c = tv.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt7;
        Send_Result__c sr7 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt7.Id
        );
        insert sr7; 
        Notification__c nt8 = new Notification__c(
            Target_Record_Ids__c = tv.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt8;
        Send_Result__c sr8 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt8.Id
        );
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
        Notification__c nt9 = new Notification__c(
            Target_Record_Ids__c = patientVisit.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_VISIT_RESULT_TYPE,
            WhatId__c = enroll.Id,
            Status__c = 'In Progress'
        );
        insert nt9;
        Send_Result__c sr9 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt9.Id
        );
        insert sr9;
        Test.startTest();
        System.runAs(testData.participantUser) {
            PPUpdatesController.getSendResultCount('2099-05-09 07:06:11');
            PPUpdatesController.getSendResultUpdates(0, 10, '2099-05-09 07:06:11');
            PPUpdatesController.removeUpdateCard(sr1.Id);
            PPUpdatesController.removeUpdateCardForVisitResult(conId, enroll.Id, patientVisit.Id);
            PPUpdatesController.removeUpdateCardForResource(resDocStudy.Id,pt.Id,pe.Id,pt.Contact__c);
        }
        User delegateUser = testData.createPatientDelegate();
        List<Contact> conDel = [
            SELECT Id, userCommunityDelegateId__c
            FROM Contact where Email='jsmith@somemail.com'
        ];
        conDel[0].userCommunityDelegateId__c = delegateUser.Id;
        update conDel;
        System.runAs(delegateUser) {
            PPUpdatesController.removeUpdateCardForResource(resDocStudy.Id,pt.Id,null,pt.Contact__c); 
        }
        Test.stopTest();
        
    }
    @isTest
    public static void alumniParticipant() {
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.NotifyAttendees.class);
        TriggerHandlerExecutor.bypassHandler(SendResultTriggerHandler.updatewelcomeMsgflagsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ResStudyTriggerHandler.PlatformEventProcessor.class);
        TriggerHandlerExecutor.bypassHandler(ResStudyTriggerHandler.CertificateResourceProcessor.class);
        TriggerHandlerExecutor.bypassHandler(ResourceTriggerHandler.ArticleResourceProcessor.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.class);
        TestData testData = new TestData();
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class);
        TriggerHandlerExecutor.bypassHandler(ClinicalTrialProfileTriggerHandler.manageBypassedFieldsForTMDH.class);
        TriggerHandlerExecutor.bypassHandler(CTPNotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.CheckFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckDuplicatesHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.PrepareCityStateFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.CheckBecomesAdultHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateParticipantAge.class);
        TriggerHandlerExecutor.bypassHandler(PatientVisitTriggerHandler.updateEcoaEvents.class);
        
        
        testData.ctp.Relevant_Links_Are_Available__c = true;
        testData.ctp.Study_Documents_Are_Available__c = true;
        testData.ctp.Video_And_Articles_Are_Available__c = true;
        update testData.ctp;
        
        Resource__c docPtRes = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'Test Res',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document',
            Version_Date__c = System.today(),
            Language__c = 'en_US',
            RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
            .get('Study_Document')
            .getRecordTypeId()
        );
        insert docPtRes;
        
        Res_study__c resDocStudy = new Res_study__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Notify_On_Availability__c = true,
            Resource__c = docPtRes.Id,
            Visible_In_Alumni__c = true,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resDocStudy;
        
        Resource__c vedioPtRes = new Resource__c(
            Content_Type__c = 'Video',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Content_Class__c = 'Study-Specific',
            Resource_Type__c = 'Study Document',
            RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
            .get('Video')
            .getRecordTypeId()
        );
        insert vedioPtRes;
        
        Res_study__c resVideoStudy = new Res_study__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Notify_On_Availability__c = true,
            Resource__c = vedioPtRes.Id,
            Visible_In_Alumni__c = true,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resVideoStudy;
        
        Resource__c linkPtRes = new Resource__c(
            Content_Type__c = 'Relevant_Link',
            Description__c = 'testBehavior',
            Title__c = 'TestRes',
            Languages__c = 'en_US',
            Type__c = 'Relevant Links',
            URL__c = 'https://www.msn.com',
            Resource_Type__c = 'Study Document',
            RecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByDeveloperName()
            .get('Relevant_Link')
            .getRecordTypeId()
        );
        insert linkPtRes;
        
        Res_study__c resLinkStudy = new Res_study__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Notify_On_Availability__c = true,
            Resource__c = linkPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resLinkStudy;
        
        Participant_Enrollment__c enroll = TestData.pe;
        Id conId = TestData.participant.Contact__c;
        Participant__c pt = TestData.participant;
        Participant_Enrollment__c pe = TestData.pe;
        Participant_Enrollment__c pe1 = ContactService.getCurrentPE(
            testData.participantUser.ContactId
        );
        //DOC
        Notification__c nt1 = new Notification__c(
            Target_Record_Ids__c = resDocStudy.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pe.Id,
            Status__c = 'In Progress'
        );
        insert nt1;
        Send_Result__c sr1 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt1.Id
        );
        insert sr1;
        
        Notification__c nt3 = new Notification__c(
            Target_Record_Ids__c = docPtRes.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt3;
        Send_Result__c sr3 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt3.Id
        );
        insert sr3;
        //VIDEO
        Notification__c nt2 = new Notification__c(
            Target_Record_Ids__c = vedioPtRes.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt2;
        Send_Result__c sr2 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt2.Id
        );
        insert sr2;
        Notification__c nt4 = new Notification__c(
            Target_Record_Ids__c = resVideoStudy.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pe.Id,
            Status__c = 'In Progress'
        );
        insert nt4;
        Send_Result__c sr4 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt4.Id
        );
        insert sr4;
        //Link
        
        Notification__c nt5 = new Notification__c(
            Target_Record_Ids__c = linkPtRes.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt5;
        Send_Result__c sr5 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt5.Id
        );
        insert sr5;
        Notification__c nt6 = new Notification__c(
            Target_Record_Ids__c = resLinkStudy.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE,
            WhatId__c = pe.Id,
            Status__c = 'In Progress'
        );
        insert nt6;
        Send_Result__c sr6 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt6.Id
        );
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
        Notification__c nt7 = new Notification__c(
            Target_Record_Ids__c = tv.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt7;
        Send_Result__c sr7 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt7.Id
        );
        insert sr7; 
        Notification__c nt8 = new Notification__c(
            Target_Record_Ids__c = tv.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED,
            WhatId__c = pt.Id,
            Status__c = 'In Progress'
        );
        insert nt8;
        Send_Result__c sr8 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt8.Id
        );
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
        Notification__c nt9 = new Notification__c(
            Target_Record_Ids__c = patientVisit.Id,
            Recipient__c = conId,
            Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_VISIT_RESULT_TYPE,
            WhatId__c = enroll.Id,
            Status__c = 'In Progress'
        );
        insert nt9;
        Send_Result__c sr9 = new Send_Result__c(
            Target_Type__c = 'Updates',
            Status__c = 'In Progress',
            Notification__c = nt9.Id
        );
        insert sr9;
        Test.startTest();
        Contact contact = ContactService.getContact(testData.participantUser.ContactId);       
        pe1.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        update pe1;
        User delegateUser = testData.createPatientDelegate();
        List<Contact> conDel = [
            SELECT Id, userCommunityDelegateId__c
            FROM Contact where Email='jsmith@somemail.com'
        ];
        conDel[0].userCommunityDelegateId__c = testData.participant.Contact__c;
        update conDel;
        System.runAs(delegateUser) {
            PPUpdatesController.getSendResultCount('2099-05-09 07:06:11');
            PPUpdatesController.getSendResultUpdates(0, 10, '2099-05-09 07:06:11');
            PPUpdatesController.removeUpdateCardForResource(resDocStudy.Id,pt.Id,null,pt.Contact__c); 
        }
        Test.stopTest();
        
    }
    @isTest
    public static void delegate() {
        TestData testData = new TestData();
        System.runAs(testData.createPatientDelegate()) {
            PPUpdatesController.getSendResultCount('2099-05-09 07:06:11');
            PPUpdatesController.getSendResultUpdates(0, 10, '2099-05-09 07:06:11');
        }
    }
    @isTest
    public static void test_removeScheduledRescheduledCard() {
        TestData testData = new TestData();
        Participant_Enrollment__c per = [
            SELECT
            id,
            Participant_Contact__c,
            PI_Contact__c,
            Participant__c,
            Study_Site__r.Clinical_Trial_Profile__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        Televisit__c tv = new Televisit__c();
        tv.Participant_Enrollment__c = per.Id;
        tv.Title__c = 'Test';
        tv.Duration__c = '30 minutes';
        tv.Visit_Date_Time__c = System.now().addMinutes(-50);
        tv.Visit_End_Date_Time__c = System.now().addminutes(30);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.NotifyAttendees.class);
        insert tv;
        Notification__c n = new Notification__c();
        n.Recipient__c = per.Participant_Contact__c;
        n.WhatId__c = per.Id;
        n.Target_Record_Ids__c = '' + tv.Id;
        n.Status__c = 'Pending';
        n.Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED;
        insert n;
        Test.startTest();
        Database.executeBatch(new Batch_UpdatePendingNotifications());
        Test.stopTest();
        PPUpdatesController.removeScheduledAndRescheduledUpdateNotifications(
            per.Participant_Contact__c,
            per.Id,
            per.Participant__c
        );
    }
    
    @isTest
    public static void test_removeCanceledCard() {
        TestData testData = new TestData();
        Participant_Enrollment__c per = [
            SELECT
            id,
            Participant_Contact__c,
            PI_Contact__c,
            Participant__c,
            Study_Site__r.Clinical_Trial_Profile__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        Televisit__c tv = new Televisit__c();
        tv.Participant_Enrollment__c = per.Id;
        tv.Title__c = 'Test';
        tv.Duration__c = '30 minutes';
        tv.Visit_Date_Time__c = System.now().addMinutes(-50);
        tv.Visit_End_Date_Time__c = System.now().addminutes(30);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.TelevisitEventTrigger.class);
        TriggerHandlerExecutor.bypassHandler(TelevisitTriggerHandler.NotifyAttendees.class);
        insert tv;
        Notification__c n = new Notification__c();
        n.Recipient__c = per.Participant_Contact__c;
        n.WhatId__c = per.Id;
        n.Target_Record_Ids__c = '' + tv.Id;
        n.Status__c = 'Pending';
        n.Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED;
        insert n;
        Test.startTest();
        Database.executeBatch(new Batch_UpdatePendingNotifications());
        Test.stopTest();
        PPUpdatesController.removeCancelledUpdateNotifications(
            per.Participant_Contact__c,
            per.Id,
            per.Participant__c
        );
    }
}