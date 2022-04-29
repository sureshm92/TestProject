@isTest
public without sharing class PIR_StatusDetailControllerTest {
    
    @TestSetup
    static void init(){
        TestData.loadTestData();
        
    }

    @isTest 
    static void testgetStatusDetail() {
        TestData testData = new TestData();
        PIR_ParticipantStatusWorflowStep__mdt mdtRec = [SELECT Id,DeveloperName,Default_Description__c,
        Failure_Criteria__c,In_progress_criteria__c,List_of_Statuses__c,Name__c,Order__c,Success_Criteria__c FROM
        PIR_ParticipantStatusWorflowStep__mdt LIMIT 1 ];
       
        List<Study_Site__c> ssList = [Select Id FROM Study_Site__c];
        List<Id> ssIds = new List<Id>();
        for(Study_Site__c ss:ssList) {
            ssIds.add(ss.Id);
        }
        Test.startTest();
         Participant_Enrollment__c parList = [SELECT Id, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c FROM Participant_Enrollment__c LIMIT 1];
        parList.Initial_visit_scheduled_date__c = system.today();
        update parList;
        PIR_StatusDetailController.getStatusDetail(testData.pe.Id);
        PIR_StatusDetailController.getGroupIcon(mdtRec,'success');
        PIR_StatusDetailController.getoutcomeToReasonMap('PWS_Eligibility_Card_Name');
        PIR_StatusDetailController.getPERdetails(testData.pe.Id);
        PIR_StatusDetailController.getRecievedHistory(testData.pe.Id);
           
        try{
            PIR_StatusDetailController.getRecievedHistory('');  
        }        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Invalid id: ' );}
		
        PIR_StatusDetailController.getContactHistory(testData.pe.Id,'PWS_Contact_Name');
        PIR_StatusDetailController.getContactHistory(parList.Id,'PWS_Contact_Name');
        PIR_StatusDetailController.getMasked(true,'CC','Test');
        PIR_StatusDetailController.getMasked(true,'CC1','Test');
        PIR_StatusDetailController.getUTCDateTime(system.now());
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        //PIR_StatusDetailController.getStudySiteVisitPlansMap(ssIds);
        PIR_StatusDetailController.isPESHnotDisabled(null,null,false);
        
        //getVisitPlansLVList

        Test.stopTest();
    }

    @isTest 
    static void testgetStatusDetail_stausChange() {
        TestData testData = new TestData();
        PIR_ParticipantStatusWorflowStep__mdt mdtRec = [SELECT Id,DeveloperName,Default_Description__c,
        Failure_Criteria__c,In_progress_criteria__c,List_of_Statuses__c,Name__c,Order__c,Success_Criteria__c FROM
        PIR_ParticipantStatusWorflowStep__mdt LIMIT 1 ];
        
        List<Study_Site__c> ssList = [Select Id FROM Study_Site__c];
        List<Id> ssIds = new List<Id>();
        for(Study_Site__c ss:ssList) {
            ssIds.add(ss.Id);
        }
        testData.ctp.Initial_Visit_Required__c = true;
        testData.pe.Clinical_Trial_Profile__c = testData.ctp.Id;
        byPassTriggersMethod();
        update testData.ctp;
        update testData.pe;
        Test.startTest();
        PIR_StatusDetailController.getStatusDetail(testData.pe.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetBubbleStatus() {
        TestData testData = new TestData();
        testData.ctp.Participant_Workflow_Final_Step__c = 'Enrollment';
        testData.pe.Participant_Status__c = 'Enrollment Success';
        byPassTriggersMethod();
        update testData.ctp;
        update testData.pe;
        Test.startTest();
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        testData.pe.Participant_Status__c = 'Trial Complete';
        update testData.pe;
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        Test.stopTest();       
    }

    @isTest
    static void testGetBubbleStatus2() {
        TestData testData = new TestData();
        testData.ctp.Participant_Workflow_Final_Step__c = 'Randomization';
        testData.pe.Participant_Status__c = 'Randomization Success';
        byPassTriggersMethod();
        update testData.ctp;
        update testData.pe;

        Test.startTest();
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        testData.pe.Participant_Status__c = 'Trial Complete';
        update testData.pe;
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        try{
            PIR_StatusDetailController.getBubbleStatus(testData.ctp.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void testGetContactHistory() {
        TestData testData = new TestData();
        Participant_Enrollment__c parList = [SELECT Id, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c FROM Participant_Enrollment__c LIMIT 1];
        List<Participant_Enrollment__History> parHistoryList = new List<Participant_Enrollment__History>();
        Time myTime = Time.newInstance(1, 2, 3, 0);
        parList.Initial_visit_scheduled_date__c = system.today();
        parList.Initial_visit_scheduled_time__c = myTime;

        Participant_Enrollment__History history1 = new Participant_Enrollment__History();
        history1.Field = 'Initial_visit_scheduled_date__c';
        history1.ParentId = parList.Id;
        parHistoryList.add(history1);

        Participant_Enrollment__History history2 = new Participant_Enrollment__History();
        history2.Field = 'Initial_visit_scheduled_time__c';
        history2.ParentId = parList.Id;
        parHistoryList.add(history2);

        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = parList.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        peshList.add(pehistory1);

        Participant_Enrollment_Status_History__c pehistory2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Pre-review Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = parList.Id
        );

        peshList.add(pehistory2);

        byPassTriggersMethod();
        update parList;

        insert parHistoryList;
        insert peshList;

        Test.startTest();
        System.runAs(testData.piUser) {
            PIR_StatusDetailController.getContactHistory(parList.Id,'PWS_Contact_Name');
        }
        Test.stopTest();

    }

    @isTest
    static void testGetContactHistory2() {
        TestData testData = new TestData();
        Participant_Enrollment__c parList = [SELECT Id, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c FROM Participant_Enrollment__c LIMIT 1];
        List<Participant_Enrollment__History> historyList = new List<Participant_Enrollment__History>();
        Time myTime = Time.newInstance(1, 2, 3, 0);
        parList.Initial_visit_scheduled_date__c = system.today();
        parList.Initial_visit_scheduled_time__c = myTime;
        Participant_Enrollment__History history1 = new Participant_Enrollment__History();
        history1.Field = 'Initial_visit_scheduled_date__c';
        history1.ParentId = parList.Id;
        historyList.add(history1);

        Participant_Enrollment__History history2 = new Participant_Enrollment__History();
        history2.Field = 'Initial_visit_scheduled_time__c';
        history2.ParentId = parList.Id;
        historyList.add(history2);
        
         Participant_Enrollment__History history3 = new Participant_Enrollment__History();
        history3.Field = 'Initial_visit_scheduled_time__c';
        history3.ParentId = parList.Id;
        insert history3;
        
        //update history3;
         
        
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = parList.Id
        );
        peshList.add(pehistory1);

        Participant_Enrollment_Status_History__c pehistory2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Received',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = parList.Id
        );

        peshList.add(pehistory2);
        
        byPassTriggersMethod();
        update parList;        

        insert historyList;
        insert peshList;
        Test.startTest();
        //System.runAs(testData.piUser) {
            PIR_StatusDetailController.getContactHistory(parList.Id,'PWS_Contact_Name');
        //}
        Test.stopTest();

    }

    @isTest
    static void testGetEligibilityHistory() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date # test on another date',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history1);

        Participant_Enrollment_Status_History__c history2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 on test date',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history2);

        Participant_Enrollment_Status_History__c history3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Failed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 on test date',
            ParticipantEnrollment__c = testData.pe.Id,
              Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes1 testing 1 testclass code1 on test date'
        );

        peshList.add(history3);

        byPassTriggersMethod();
        insert peshList;

        Test.startTest();
        PIR_StatusDetailController.getEligibilityHistory(testData.pe.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetInitialVisitHistory() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code on this date # another test with on another date',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history1);

        byPassTriggersMethod();
        insert peshList;

        Test.startTest();
        PIR_StatusDetailController.getInitialVisitHistory(testData.pe.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetScreeningHistory() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening In Progress',
            Additional_Notes__c = 'Test Notes testing testclass code on this date',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c = 'PI Decision',
            Notes__c = 'Test Notes1 testing 1 testclass code1 on test date'
        );
        peshList.add(history1);
        Participant_Enrollment_Status_History__c history2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 on test date',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history2);

        byPassTriggersMethod();
        insert peshList;

        Test.startTest();
        PIR_StatusDetailController.getScreeningHistory(testData.pe.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetScreeningHistory_Exception() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();

        Participant_Enrollment_Status_History__c history2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 test date',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history2);

        byPassTriggersMethod();
        insert peshList;

        Test.startTest();
        try{
            PIR_StatusDetailController.getScreeningHistory(testData.pe.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void testGetEnrollmentHistory() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Enrollment Success',
            Additional_Notes__c = 'Test Notes testing testclass code on this date',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c = 'PI Decision',
            Notes__c = 'Test Notes1 testing 1 testclass code1 on test date'
        );

        peshList.add(history1);

        Participant_Enrollment_Status_History__c history2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 on test date',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history2);
        byPassTriggersMethod();
        insert peshList;

        Test.startTest();
        try{
            PIR_StatusDetailController.getEnrollmentHistory(testData.pe.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void testGetEnrollmentHistory_exception() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 on test date',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c = 'PI Decision',
            Notes__c = 'Test Notes1 testing 1 testclass code1 on test date'
        );

        peshList.add(history3);

        Participant_Enrollment_Status_History__c history4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 test date',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history4);
        byPassTriggersMethod();
        insert peshList;

        Test.startTest();
        try{
            PIR_StatusDetailController.getEnrollmentHistory(testData.pe.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void testStudySiteVisitPlanMap() {
        TestData testData = new TestData();
        List<Study_Site__c> ssList = [Select Id FROM Study_Site__c];
        List<Id> ssIds = new List<Id>();
        for(Study_Site__c ss:ssList) {
            ssIds.add(ss.Id);
        }

        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test_StudySiteVisitConfigRemote VP');
        insert visitPlan;

        StudySiteVisitPlan__c studyVisitPlan = new StudySiteVisitPlan__c();
        studyVisitPlan.Study_Site__c = ssIds[0];
        studyVisitPlan.Visit_Plan__c = visitPlan.Id;
        insert studyVIsitPlan;

        Test.startTest();
        PIR_StatusDetailController.getStudySiteVisitPlansMap(ssIds);
        PIR_StatusDetailController.getVisitPlansLVList(ssIds[0]);
        Test.stopTest();
    }

    @isTest
    static void testDoSaveStatusDetails() {
        TestData testData = new TestData();
        List<Participant_Enrollment__c> parList = [SELECT Id,
        Non_Enrollment_Reason__c,
        Visit_Plan__c,
        ParticipantNoShow__c,
        Participant_Status__c,
        Last_Status_Changed_Notes__c,
        Clinical_Trial_Profile__r.Initial_Visit_Required__c,
        Initial_visit_scheduled_date__c,
        Initial_visit_scheduled_time__c,
        Initial_visit_occurred_flag__c,
        Last_Status_Changed_Additional_Notes__c FROM
        Participant_Enrollment__c
        ];

        byPassTriggersMethod();
        parList[0].ParticipantNoShow__c = true;
        parList[0].Non_Enrollment_Reason__c = 'Didn\'t Show For Initial Visit';
        parList[2].Participant_Status__c = null;
        parList[2].Last_Status_Changed_Additional_Notes__c = 'test';
        parList[1].Participant_Status__c = 'Eligibility Passed';

        update parList;
        Test.startTest();
        PIR_StatusDetailController.doSaveStatusDetails(parList[0],'');
        PIR_StatusDetailController.doSaveStatusDetails(parList[1],'');
        PIR_StatusDetailController.doSaveStatusDetails(parList[2],'');
        try{
            //parList[0].Non_Enrollment_Reason__c = 'test Show For Initial Visit';
            PIR_StatusDetailController.doSaveStatusDetails(new Participant_Enrollment__c(),'');
        }catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        Test.stopTest();
    }
    

    static void byPassTriggersMethod() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.prepareAdditionalFields.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PETriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );        
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );


    }


}