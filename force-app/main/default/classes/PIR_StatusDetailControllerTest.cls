@isTest
public without sharing class PIR_StatusDetailControllerTest {
    static List<User> usrList;
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
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].Initial_Visit_Required__c = false;
        update ctpList; 
        PIR_StatusDetailController.getStatusDetail(testData.pe.Id);
        PIR_StatusDetailController.getGroupIcon(mdtRec,'success');
        PIR_StatusDetailController.getGroupIcon(mdtRec,'Failed');
        PIR_StatusDetailController.getoutcomeToReasonMap('PWS_Eligibility_Card_Name');
        PIR_StatusDetailController.getPERdetails(testData.pe.Id);
        PIR_StatusDetailController.getRecievedHistory(testData.pe.Id);
        Test.stopTest();
    }
    
    @isTest 
    static void testgetStatusDetail2() {
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
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].Initial_Visit_Required__c = false;
        update ctpList; 
        
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
    static void testgetRecievedHistory_Exception() {
        TestData testData = new TestData();
        Test.startTest();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = testData.pe.Participant_Status__c,
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        peshList.add(pehistory1);
        byPassTriggersMethod();
        insert peshList;
        
        PIR_StatusDetailController.getRecievedHistory(testData.pe.Id);
        Test.stopTest();
    }

    @isTest 
    static void testgetStatusDetail_stausChange() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Pre-review Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        peshList.add(pehistory1);
        Test.startTest();
        byPassTriggersMethod();
        insert peshList;
        List<Study_Site__c> ssList = [Select Id FROM Study_Site__c];
        List<Id> ssIds = new List<Id>();
        for(Study_Site__c ss:ssList) {
            ssIds.add(ss.Id);
        }
        testData.ctp.Initial_Visit_Required__c = true;
        testData.pe.Clinical_Trial_Profile__c = testData.ctp.Id;
        
        byPassTriggersMethod();
        update testData.ctp;
        byPassTriggersMethod();
        update testData.pe;
        
        PIR_StatusDetailController.getStatusDetail(testData.pe.Id);
        testData.pe.Informed_Consent__c = true;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        testData.pe.Participant_Status__c    = 'Declined Consent';
        testData.pe.Initial_visit_scheduled_date__c = system.today();
        testData.pe.Initial_visit_scheduled_time__c = myTime;
        testData.ctp.Participant_Workflow_Final_Step__c = 'Enrollment';
        update testData.ctp;
        update testData.pe;
        PIR_StatusDetailController.getStatusDetail(testData.pe.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetBubbleStatus() {
        TestData testData = new TestData();
        
        Test.startTest();
        testData.ctp.Participant_Workflow_Final_Step__c = 'Enrollment';
        testData.pe.Participant_Status__c = 'Enrollment Success';
        byPassTriggersMethod();
        update testData.ctp;
        update testData.pe;
        
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        testData.pe.Participant_Status__c = 'Trial Complete';
        update testData.pe;
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        Test.stopTest(); 
    }

    @isTest
    static void testGetBubbleStatus2() {
        TestData testData = new TestData();
        Test.startTest();
        testData.ctp.Participant_Workflow_Final_Step__c = 'Randomization';
        testData.pe.Participant_Status__c = 'Randomization Success';
        byPassTriggersMethod();
        update testData.ctp;
        update testData.pe;

        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        testData.pe.Participant_Status__c = 'Trial Complete';
        update testData.pe;
        PIR_StatusDetailController.getBubbleStatus(testData.pe.Id);
        try{
            //PIR_StatusDetailController.getBubbleStatus(testData.ctp.Id);
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void testGetContactHistory() {
        
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        Time myTime = Time.newInstance(1, 2, 3, 0);
        //Participant_Enrollment__c parList = [SELECT Id, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c FROM Participant_Enrollment__c LIMIT 1];
         Test.startTest();
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Study_Site__c = ssList[0].Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral',
            Screening_ID__c = 'PESCR1',
            Birth_Month__c='04',
            YOB__c='2000',
            Informed_Consent__c=false
        );
        insert parList;
        List<Participant_Enrollment__History> parHistoryList = new List<Participant_Enrollment__History>();
        parList.Initial_visit_scheduled_date__c = system.today();
        parList.Initial_visit_scheduled_time__c = myTime;
         Participant_Enrollment__History history3 = new Participant_Enrollment__History();
        history3.Field = 'created';
        history3.ParentId = parList.Id;
        parHistoryList.add(history3);
        
        Participant_Enrollment__History history1 = new Participant_Enrollment__History();
        history1.Field = 'Initial_visit_scheduled_date__c';
        history1.ParentId = parList.Id;
        parHistoryList.add(history1);

        Participant_Enrollment__History history2 = new Participant_Enrollment__History();
        history2.Field = 'Initial_visit_scheduled_time__c';
        history2.ParentId = parList.Id;
        parHistoryList.add(history2);
        
        Participant_Enrollment__History history4 = new Participant_Enrollment__History();
        history4.Field = 'High_Priority__c';
        history4.ParentId = parList.Id;
        parHistoryList.add(history4);

        Participant_Enrollment__History history5 = new Participant_Enrollment__History();
        history5.Field = 'Informed_Consent__c';
        history5.ParentId = parList.Id;
        parHistoryList.add(history5);
        
        Participant_Enrollment__History history6 = new Participant_Enrollment__History();
        history6.Field = 'Informed_Consent__c';
        history6.ParentId = parList.Id;
        parHistoryList.add(history6);

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
            Additional_Notes__c = 'Test Notes testing $ testclass code this date by test user (IQVIA)',
            ParticipantEnrollment__c = parList.Id
        );

        peshList.add(pehistory2);

        Participant_Enrollment_Status_History__c pehistory3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Pre-review Passed',
            Additional_Notes__c = 'Test Notes testing # testclass code on this date by test user (IQVIA)',
            ParticipantEnrollment__c = parList.Id
        );

        peshList.add(pehistory3);
        Participant_Enrollment_Status_History__c pehistory4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Pre-review Passed',
            Additional_Notes__c = 'Test Notes testing testclass code  this date by test user',
            ParticipantEnrollment__c = parList.Id
        );

        peshList.add(pehistory4);

        byPassTriggersMethod();
        //parList.High_Priority__c = true;
        update parList;

        insert parHistoryList;
        insert peshList;
       
        System.runAs(testData.piUser) {
            PIR_StatusDetailController.getContactHistory(parList.Id,'PWS_Contact_Name');
            PIR_StatusDetailController.getScreeningHistory(testData.pe.Id);
        }
        Test.stopTest();

    }

    @isTest
    static void testGetContactHistoryCreation() {
        TestData testData = new TestData();
        Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        Time myTime = Time.newInstance(1, 2, 3, 0);
        
        usrList = [SELECT Id,profileId,IsPortalEnabled FROM User WHERE Id =: testData.piUser.Id];
        //usrList[0].profileId = Userinfo.getProfileId();
        usrList[0].IsPortalEnabled = true;
        update usrList;
      // Participant_Enrollment__c parList = [SELECT Id, Initial_visit_scheduled_date__c,Initial_visit_scheduled_time__c FROM Participant_Enrollment__c LIMIT 1];
      
        try{
            System.runAs(usrList[0]) {            
                PIR_StatusDetailController.getContactHistory(testData.pe.Id,null);
                 PIR_StatusDetailController.getScreeningHistory(testData.pe.Id);
            }
        }catch(Exception ex){}
        Test.stopTest();

    }

    @isTest
    static void testGetContactHistory2() {
        TestData testData = new TestData();
        Participant_Enrollment__c parList = [SELECT Id, Initial_visit_scheduled_date__c,Informed_Consent__c,Initial_visit_scheduled_time__c FROM Participant_Enrollment__c LIMIT 1];
        List<Participant_Enrollment__History> historyList = new List<Participant_Enrollment__History>();
        Time myTime = Time.newInstance(1, 2, 3, 0);
        parList.Initial_visit_scheduled_date__c = system.today();
        parList.Initial_visit_scheduled_time__c = myTime;
        parList.Informed_Consent__c=true;
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
        
        Participant_Enrollment__History history4 = new Participant_Enrollment__History();
        history4.Field = 'Informed_Consent__c';
        history4.ParentId = parList.Id;
        insert history4;
        
        Participant_Enrollment__History history5= new Participant_Enrollment__History();
        history5.Field = 'Informed_Consent__c';
        history5.ParentId = parList.Id;
        insert history5;
        
        
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
            Additional_Notes__c = 'Test Notes testing testclass code on this date by iqvia',
            ParticipantEnrollment__c = parList.Id
        );
        peshList.add(pehistory2);

        Participant_Enrollment_Status_History__c pehistory5 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code  this date by (iqvia)',
            ParticipantEnrollment__c = parList.Id
        );
        peshList.add(pehistory5);

        Participant_Enrollment_Status_History__c pehistory3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Received',
            Additional_Notes__c = 'Test Notes testing testclass code this date by iqvia',
            ParticipantEnrollment__c = parList.Id
        );
        peshList.add(pehistory3);

        Participant_Enrollment_Status_History__c pehistory6 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Received',
            Additional_Notes__c = 'Test Notes testing testclass # code this on date by (iqvia)',
            ParticipantEnrollment__c = parList.Id
        );
        peshList.add(pehistory6);
        Participant_Enrollment_Status_History__c pehistory7 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Received',
            Additional_Notes__c = 'Test Notes testing testclass # code this date by (iqvia)',
            ParticipantEnrollment__c = parList.Id
        );
        peshList.add(pehistory7);

        Participant_Enrollment_Status_History__c pehistory4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code this date by (iqvia)',
            ParticipantEnrollment__c = parList.Id
        );

        peshList.add(pehistory4);
        Test.startTest();
        byPassTriggersMethod();
        update parList;        

        insert historyList;
        insert peshList;
        
        System.runAs(testData.piUser) {
            PIR_StatusDetailController.getContactHistory(parList.Id,'PWS_Contact_Name');
            PIR_StatusDetailController.getScreeningHistory(testData.pe.Id);
        }
        Test.stopTest();

    }

    @isTest
    static void testGetEligibilityHistory() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date # test on another date by (iqvia)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history1);

        Participant_Enrollment_Status_History__c history4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass # code this date test another date (iqvia)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history4);
        Participant_Enrollment_Status_History__c history6 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code this date # test on another date iqvia',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history6);

        Participant_Enrollment_Status_History__c history2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes1 testing # 1 testclass code1 on test date',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history2);

        Participant_Enrollment_Status_History__c history5 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes1 testing 1 # testclass code1  test date (iqvia)',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history5);

        Participant_Enrollment_Status_History__c history7 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 on test date (iqvia)',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history7);
        Participant_Enrollment_Status_History__c history3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Failed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 on test date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id,
              Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes1 testing 1 testclass code1 on test date'
        );

        peshList.add(history3);

        Participant_Enrollment_Status_History__c history10 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Failed',
            Additional_Notes__c = 'Test Notes1 testing # 1 testclass code1 test date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id,
              Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes1 testing 1 testclass code1 on test date'
        );

        peshList.add(history10);
        Participant_Enrollment_Status_History__c history11 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Failed',
            Additional_Notes__c = 'Test Notes1 testing # 1 testclass code1 on test date',
            ParticipantEnrollment__c = testData.pe.Id,
              Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes1 testing 1 testclass code1 on test date'
        );

        peshList.add(history11);

        Test.startTest();
        byPassTriggersMethod();
        insert peshList;

        PIR_StatusDetailController.getEligibilityHistory(testData.pe.Id);
        testData.ctp.Promote_To_SH__c = true;
        testData.ctp.DCT_Platform__c = 'Study Hub';
        update testData.ctp;
        PIR_StatusDetailController.getEligibilityHistory(testData.pe.Id);
        try{
            PIR_StatusDetailController.getEligibilityHistory('234');
        }catch(Exception ex){}
        Test.stopTest();
    }

    @isTest
    static void testGetInitialVisitHistory() {
        TestData testData = new TestData();
        Test.startTest();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code on this date # another test with on another date',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history1);
        Participant_Enrollment_Status_History__c history3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code on this date # another test with on another date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history3);

        Participant_Enrollment_Status_History__c history2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code on this date # another test with another date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history2);

        Participant_Enrollment_Status_History__c history4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully Contacted',
            Additional_Notes__c = 'Test Notes testing testclass code this date # another test with another date',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history4);

        byPassTriggersMethod();
        insert peshList;

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
        Participant_Enrollment_Status_History__c history3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Ready to Screen',
            Additional_Notes__c = 'Test Notes testing # testclass code on this date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c = 'PI Decision',
            Notes__c = 'Test Notes1 testing 1 testclass code1 test date (iqvia)'
        );
        peshList.add(history3);
        Participant_Enrollment_Status_History__c history4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes1 testing # 1 testclass code1 on test date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history4);
        Participant_Enrollment_Status_History__c history5 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening In Progress',
            Additional_Notes__c = 'Test Notes1 testing # 1 testclass code1 test date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history5);

        Participant_Enrollment_Status_History__c history6 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 # testclass code1 test date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history6);
        Test.startTest();
        byPassTriggersMethod();
        insert peshList;

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
        Test.startTest();
        byPassTriggersMethod();
        insert peshList;

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
            Notes__c = 'Test Notes1 testing 1 testclass code1 on test date (IQVIA)'
        );

        peshList.add(history1);

        Participant_Enrollment_Status_History__c history2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Enrollment Success',
            Additional_Notes__c = 'Test Notes1 testing on 1 (IQVIA) # testclass code1 on test date iqvia',
            ParticipantEnrollment__c = testData.pe.Id
        );

        peshList.add(history2);

        Participant_Enrollment_Status_History__c history3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Enrollment Success',
            Additional_Notes__c = 'Test Notes1 testing 1  # testclass code1 test date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history3);
        Participant_Enrollment_Status_History__c history4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 on (IQVIA)  # testclass code1 test on date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history4);
        Test.startTest();
        byPassTriggersMethod();
        insert peshList;

        try{
            PIR_StatusDetailController.getEnrollmentHistory(testData.pe.Id);
        }catch(Exception ex){}
        try{
            PIR_StatusDetailController.getEnrollmentHistory('testData.pe.Id');
        }catch(Exception ex) {}
        
        Test.stopTest();
    }

    @isTest
    static void testGetEnrollmentHistory_exception() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history3 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening Passed',
            Additional_Notes__c = 'Test Notes1 # testing 1 testclass code1 test date on iqvia',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c = 'PI Decision',
            Notes__c = 'Test Notes1 testing 1 testclass code1 test date'
        );

        peshList.add(history3);

        Participant_Enrollment_Status_History__c history4 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening Passed',
            Additional_Notes__c = 'Test Notes1 testing 1 testclass code1 test date (IQVIA)',
            ParticipantEnrollment__c = testData.pe.Id
        );
        peshList.add(history4);
        Test.startTest();
        byPassTriggersMethod();
        insert peshList;

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
        Test.startTest();

        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test_StudySiteVisitConfigRemote VP');
        insert visitPlan;

        StudySiteVisitPlan__c studyVisitPlan = new StudySiteVisitPlan__c();
        studyVisitPlan.Study_Site__c = ssIds[0];
        studyVisitPlan.Visit_Plan__c = visitPlan.Id;
        insert studyVIsitPlan;

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
        Participant__r.Gender__c,
        Add_televisit_for_Initial_Visit__c,
        Initial_Visit_Televisit_Created__c,
        Initial_visit_scheduled_date__c,
        Initial_visit_scheduled_time__c,
        Initial_visit_occurred_flag__c,
        PI_Contact__c, 
        Participant__c,
        Participant_Contact__c, 
        PI_Contact__r.FirstName, 
        PI_Contact__r.LastName,
        Participant__r.First_Name__c, 
        Participant__r.Last_Name__c,
        Participant__r.Adult__c,
        Participant__r.Email__c,
        Last_Status_Changed_Additional_Notes__c FROM
        Participant_Enrollment__c
        ];
      
       
        
        byPassTriggersMethod();
        parList[0].ParticipantNoShow__c = true;
        parList[0].Add_televisit_for_Initial_Visit__c = true;
        parList[0].Initial_Visit_Televisit_Created__c = false;
        parList[0].Initial_visit_scheduled_date__c = system.today().addDays(2);
        parList[0].Initial_visit_scheduled_time__c = Time.newInstance(18, 30, 2, 20);
        parList[0].Non_Enrollment_Reason__c = 'Didn\'t Show For Initial Visit';
        parList[2].Participant_Status__c = null;
        parList[2].Last_Status_Changed_Additional_Notes__c = 'test';
        parList[1].Participant_Status__c = 'Eligibility Passed';
        Test.startTest();
        update parList;
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Screening In Progress',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = parList[2].Id,
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        peshList.add(pehistory1);
        byPassTriggersMethod();
        insert peshList;
        Participant__c perRec= [select Id,Gender__c from Participant__c where Email__c='part1@email.com' limit 1];
        perRec.Gender__c='Female';
        try{
        PIR_StatusDetailController.doSaveStatusDetails(parList[0],perRec,'',false);
        PIR_StatusDetailController.doSaveStatusDetails(parList[1],perRec,'',false);
        PIR_StatusDetailController.doSaveStatusDetails(parList[2],perRec,'',false);
        PIR_StatusDetailController.doSaveStatusDetails(parList[2],perRec,vp.id,false);
        }
        catch(Exception ex){
             
        }

        try{
            parList[0].Non_Enrollment_Reason__c = 'test Show For Initial Visit';
            PIR_StatusDetailController.doSaveStatusDetails(new Participant_Enrollment__c(),new Participant__c(),'',false);
        }catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        
        Test.stopTest();
    }
    
    @isTest
    static void testIsSuccessfullyReEngaged() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> peshList = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c history1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Successfully re-engaged',
            Additional_Notes__c = 'Test Notes testing testclass code on this date',
            ParticipantEnrollment__c = testData.pe.Id,
            Notes__c = 'Test Notes1 testing 1 testclass code1 on test date (IQVIA)'
        );

        peshList.add(history1);
        Test.startTest();
        byPassTriggersMethod();
        insert peshList;

        try{
            PIR_StatusDetailController.isSuccessfullyReEngaged(testData.pe.Id);
        }catch(Exception ex){}
        try{
            PIR_StatusDetailController.isSuccessfullyReEngaged('testData.pe.Id');
        }catch(Exception ex) {}
        
        Test.stopTest();
    }

    static void byPassTriggersMethod() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.class
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
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreatePeshafterUpdate.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );

        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.DefaultEcoaTask.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.createNotifications.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.EcoaEvents.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.StudyConsentTimestamps.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.UpdatePatientConsent.class
        );
        
        TriggerHandlerExecutor.bypassHandler(
            TelevisitTriggerHandler.NotifyAttendees.class
        );

    }
}