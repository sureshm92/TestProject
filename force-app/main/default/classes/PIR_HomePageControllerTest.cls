@isTest
public without sharing class PIR_HomePageControllerTest {
    static List<String> status = new List<String>();
    @TestSetup
    static void init(){
        TestData.loadTestData();
        
        status.add('Received');
        status.add('Pre-review Passed');
        status.add('In Wash Out Period');
        status.add('Successfully Contacted');
        status.add('Contact Attempted');
        status.add('Eligibility Passed');
        status.add('Screening Passed');
        status.add('Screening In Progress');
        status.add('Screening Passed');
        status.add('Screening Failed');
        status.add('Screening In Progress - Wash Out Period');
        status.add('Ready to Screen');
        status.add('Enrollment Success');
        status.add('Randomization Success');
        status.add('Pre-review Failed');
        status.add('Unable to Reach');
        status.add('Contacted - Not Suitable');
        status.add('Eligibility Failed');
        status.add('Declined Consent');
        status.add('Unable to Screen');
        status.add('Withdrew Consent');
        status.add('Withdrew Consent After Screening');
        status.add('Enrollment Failed');
        status.add('Randomization Failed');
        status.add('Randomization Success');
        status.add('Treatment Period Started');
        status.add('Follow-Up Period Started');
        status.add('Participation Complete');
        status.add('Trial Complete');
        status.add('Declined Final Consent');
    }
    
    @isTest static void testgetListViewData() {
        // TestData.loadTestData();
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<String> ctpIdList = new List<String>();
        List<Id> ssIdList = new List<Id>();
        
        
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id); 
        ssIdList.add(ssList[0].Id);
        Test.startTest();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Clinical_Trial_Profile__c=ctpList[0].id;
        partEnroll.Study_Site__c=ssList[0].Id;
        partEnroll.Participant_Status__c='Received';
        partEnroll.Referral_Source__c='Principal Investigator';
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        String filterlist = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Eligibility Passed"],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnew = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Not Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Sent to DCT"],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Sent to DCT","Eligibility Passed"],"studyList":[],"activeInactive":"Inactive"}';
        String filterlist1 = '{"activeInactive":"Active","ageFrom":"150","ageTo":"0","comorbidities":"false","ethnicityList":[],"highPriority":false,"highRisk":"false","initialVisit":"All","isDefault":true,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Received","Sent to DCT","Eligibility Passed"],"studyList":["'+ctpList[0].id+'"]}';
        
        
        System.runAs(testData.piUser) {
            PIR_HomepageController.getListViewData(1,2,'Janssen',filterlistnull,true,true,'','',1);
           
            try{
                 PIR_HomepageController.getListViewData(1,2,'Default',filterlistnull,true,false,'','',1);
                PIR_HomepageController.getListViewData(1,2,'Janssen',filterlistnull,true,false,'','AND',1);
                
            }
            catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
            
            
            
        }
       
        Test.stopTest();
    }
    @isTest static void testgetListViewDataNew() {
        // TestData.loadTestData();
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<String> ctpIdList = new List<String>();
        List<Id> ssIdList = new List<Id>();
        
        
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id); 
        ssIdList.add(ssList[0].Id);
        Test.startTest();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Participant__r.First_Name__c,Show_Referring_Provider__c
            FROM Participant_Enrollment__c where Participant__r.First_Name__c!=null
            LIMIT 1
        ]; 
        partEnroll.Clinical_Trial_Profile__c=ctpList[0].id;
        partEnroll.Study_Site__c=ssList[0].Id;
        partEnroll.Participant_Status__c='Received';
        partEnroll.Referral_Source__c='Principal Investigator';
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        String filterlist = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Eligibility Passed"],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnew = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Not Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Sent to DCT"],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Sent to DCT","Eligibility Passed"],"studyList":[],"activeInactive":"Inactive"}';
        String filterlist1 = '{"activeInactive":"Active","ageFrom":"150","ageTo":"0","comorbidities":"false","ethnicityList":[],"highPriority":false,"highRisk":"false","initialVisit":"All","isDefault":true,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Received","Sent to DCT","Eligibility Passed"],"studyList":["'+ctpList[0].id+'"]}';
        
        
        System.runAs(testData.piUser) {
            
            PIR_HomepageController.getListViewData(1,2,'Janssen',filterlistnew,true,true,'','',1);
            PIR_HomepageController.getListViewData(1,2,'Default',filterlist,true,true,'','',1);
            PIR_HomepageController.getListViewData(1,2,'Default',filterlist,true,false,partEnroll.Participant__r.First_Name__c,'',1);
            
        }
       
        Test.stopTest();
    }
    @isTest static void testgetListViewDataNew_1() {
        // TestData.loadTestData();
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<String> ctpIdList = new List<String>();
        List<Id> ssIdList = new List<Id>();
        
        
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id); 
        ssIdList.add(ssList[0].Id);
        Test.startTest();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Clinical_Trial_Profile__c=ctpList[0].id;
        partEnroll.Study_Site__c=ssList[0].Id;
        partEnroll.Participant_Status__c='Received';
        partEnroll.Referral_Source__c='Principal Investigator';
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        String filterlist = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Eligibility Passed"],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnew = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Not Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Sent to DCT"],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Sent to DCT","Eligibility Passed"],"studyList":[],"activeInactive":"Inactive"}';
        String filterlist1 = '{"activeInactive":"Active","ageFrom":"150","ageTo":"0","comorbidities":"false","ethnicityList":[],"highPriority":false,"highRisk":"false","initialVisit":"All","isDefault":true,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Received","Sent to DCT","Eligibility Passed"],"studyList":["'+ctpList[0].id+'"]}';
        
        
        System.runAs(testData.piUser) {    
            PIR_HomepageController.getListViewData(1,-1,'Janssen',filterlistnull,false,false,'','',1);
            PIR_HomepageController.getListViewData(1,2,'Default',filterlistnull,true,true,'','',1);
            PIR_HomepageController.getListViewData(1,2,'Default',filterlistnew,true,true,'','',1);
        }
       
        Test.stopTest();
    }
    @isTest static void testgetListViewDataNew_2() {
        // TestData.loadTestData();
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<String> ctpIdList = new List<String>();
        List<Id> ssIdList = new List<Id>();
        
        
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id); 
        ssIdList.add(ssList[0].Id);
        Test.startTest();
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Clinical_Trial_Profile__c=ctpList[0].id;
        partEnroll.Study_Site__c=ssList[0].Id;
        partEnroll.Participant_Status__c='Received';
        partEnroll.Referral_Source__c='Principal Investigator';
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        
        String filterlistnull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Sent to DCT","Eligibility Passed"],"studyList":[],"activeInactive":"Inactive"}';
        String filterlist1 = '{"activeInactive":"Active","ageFrom":"150","ageTo":"0","comorbidities":"false","ethnicityList":[],"highPriority":false,"highRisk":"false","initialVisit":"All","isDefault":true,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Received","Sent to DCT","Eligibility Passed"],"studyList":["'+ctpList[0].id+'"]}';
        
        
        System.runAs(testData.piUser) {
            PIR_HomepageController.getListViewData(1,2,'Default',filterlist1,true,true,'','',1);
            PIR_HomepageController.getListViewData(1,2,'Default',filterlistnull,false,true,'','',1);
        }
       
        Test.stopTest();
    }
    @isTest 
    static void testgetStudySite() {
        TestData testData = new TestData();
        //TestData.loadTestData();
        Test.startTest();
        System.runAs(testData.piUser) {            
            PIR_HomepageController.getStudySite();
        }
        Test.stopTest();
        
    }
    
    @isTest 
    static void testgetPEData() {
        TestData testData = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.prepareAdditionalFields.class
        );
        
         Test.startTest();
        Study_Site__c ssn= [select id from Study_Site__c];
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Study_Site__c,Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Study_Site__c=ssn.id;
        update partEnroll;        
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.piContact.id
        ];
        User u = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId=:testData.piContact.id];
        List<Site_Staff__c> SS = new List<Site_Staff__c>();
        //for (Integer i = 0; i < 20; i++) {
            Site_Staff__c s = new Site_Staff__c(
                Email__c = 'sitestaff' + 1 + '@emil.com',
                Study_Site__c=ssn.id,
                Site_Contact__c = con.id,
                Delegate_Level__c = 'Level 2',
                is_Invited__c = true
            );
           // SS.add(s);
        //}
        insert s;
       
        System.runAs(testData.piUser){
            PIR_HomepageController.getPEData(testData.pe.Id);
        }
        try{
            PIR_HomepageController.getPEData('testData.pe.Id');
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        Test.stopTest();
    }
    
    @isTest
    static void testupdateParticipantDataSH() {
        TestData testData = new TestData();
        Test.startTest();
        PIR_HomepageController.updateParticipantDataSH(testData.pe.Id);
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
        parList[0].Initial_visit_scheduled_date__c=system.today();
        update parList;
        PIR_HomepageController.updateParticipantDataSH(parList[0].id);
        
        
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];        
        try{
            PIR_HomepageController.updateParticipantDataSH(null);
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        Test.stopTest();
    }
    
    @isTest
    static void testcreateUserForPatientProtal() {
        TestData testData = new TestData();
        Account hcpAccount = new Account(Name = 'HCP Account New');
        insert hcpAccount;
        //accounts.add(hcpAccount);
        Contact ccContact = new Contact(
            FirstName = 'CCTD',
            LastName = 'CCTDnew',
            Email = 'ccnew@emil.com',
            AccountId = hcpAccount.Id,
            userCommunytyType__c = CommunityService.USER_MODE_CC,
            userCommunityMode__c = CommunityService.USER_MODE_CC
        );
        insert ccContact;
        Contact ccContactnew = new Contact(
            FirstName = 'CCTD',
            LastName = 'CCTDnew',
            Email = 'ccnew@emil.com',
            AccountId = hcpAccount.Id,
            Is_Patient_User_Created__c=false
        );
        insert ccContactnew;
        
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
        Test.startTest();
        List<Participant_Enrollment__c> peList = [SELECT Id,Participant_Contact__c,HCP__c FROM Participant_Enrollment__c WHERE Patient_ID__c=:'SomePatientId2'];
        peList[0].Participant_Contact__c = ccContact.Id;
        peList[0].HCP__c=null;
        update peList;
        List<Participant_Enrollment__c> peListnew = [SELECT Id,Participant_Contact__c,HCP_Contact__c,HCP__c FROM Participant_Enrollment__c WHERE Patient_ID__c=:'SomePatientId2'];
        peListnew[0].Participant_Contact__c = ccContactnew.Id;
        peListnew[0].HCP__c=null;
        update peListnew;
        
        PIR_HomepageController.createUserForPatientProtal(peList[0].Id);
        PIR_HomepageController.createUserForPatientProtal(peListnew[0].Id); 
        try{
            PIR_HomepageController.createUserForPatientProtal('peList[0].Id');
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        Test.stopTest();
    }
    
    @isTest
    static void testgetStudyAccessLevel() {
        TestData testData = new TestData();
        Test.startTest();
        Study_Site__c ssn= [select id from Study_Site__c];
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Study_Site__c,Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Study_Site__c=ssn.id;
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.piContact.id
        ];
        User u = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId=:testData.piContact.id];
        
        List<Site_Staff__c> SS = new List<Site_Staff__c>();
        
        Site_Staff__c s = new Site_Staff__c(
            Email__c = 'sitestaff' + 1 + '@emil.com',
            Study_Site__c=ssn.id,
            Site_Contact__c = con.id,
            Delegate_Level__c = 'Level 3',
            is_Invited__c = true);
        insert s;
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        
        System.runAs(testData.piUser) {
            PIR_HomepageController.getStudyAccessLevel();
        }
        
        Test.stopTest();
    }
    @isTest
    static void testgetStudyAccessLevelInitParent() {
        TestData testData = new TestData();
        Test.startTest();
        Study_Site__c ssn= [select id from Study_Site__c];
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Study_Site__c,Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Study_Site__c=ssn.id;
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.piContact.id
        ];
        User u = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId=:testData.piContact.id];
        
        List<Site_Staff__c> SS = new List<Site_Staff__c>();
        
        Site_Staff__c s = new Site_Staff__c(
            Email__c = 'sitestaff' + 1 + '@emil.com',
            Study_Site__c=ssn.id,
            Site_Contact__c = con.id,
            Delegate_Level__c = 'Level 3',
            is_Invited__c = true);
        insert s;
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        
        System.runAs(testData.piUser) {
            PIR_HomepageController.getStudyAccessLevelInitParent();
        }
        
        Test.stopTest();
    }
    @isTest
    static void testgetStudyAccessLevel_2() {
        TestData testData = new TestData();
        Test.startTest();
        Study_Site__c ssn= [select id from Study_Site__c];
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Study_Site__c,Show_Referring_Provider__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Study_Site__c=ssn.id;
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.piContact.id
        ];
        User u = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId=:testData.piContact.id];
        
        List<Site_Staff__c> SS = new List<Site_Staff__c>();
        Site_Staff__c s = new Site_Staff__c(
            Email__c = 'sitestaff' + 1 + '@emil.com',
            Study_Site__c=ssn.id,
            Site_Contact__c = con.id,
            Delegate_Level__c = 'Level 3',
            is_Invited__c = true);
        insert s;
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        
        System.runAs(testData.piUser) {
            PIR_HomepageController.getPEData(partEnroll.id);
        }
        
        Test.stopTest();
    }
    @isTest
    static void testgetStudyAccessLevel_3() {
        TestData testData = new TestData();
        Study_Site__c ssn= [select id from Study_Site__c];
        
        Test.startTest();
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.piContact.id
        ];
        User u = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId=:testData.piContact.id];
        
        List<Site_Staff__c> SS = new List<Site_Staff__c>();
        
        Site_Staff__c s = new Site_Staff__c(
            Email__c = 'sitestaff' + 1 + '@emil.com',
            Study_Site__c=ssn.id,
            Site_Contact__c = con.id,
            Delegate_Level__c = 'Level 3',
            is_Invited__c = true);
        insert s;
        
        System.runAs(testData.piUser) {
            PIR_HomepageController.getStudyStudySiteDetails();
            PIR_HomepageController.saveTheChunkFile('test','test','test','test');
            PIR_HomepageController.LabelValueItemISO la= new PIR_HomepageController.LabelValueItemISO('IND','IND');
            PIR_HomepageController.getISOLanguage();
            PIR_HomepageController.getParticipantsStatusesAndVisitPlans(ssn.Id);
            PIR_HomepageController.getSite(ssn.Id);
        }
        
        Test.stopTest();
    }
    @isTest
    static void testgeneralMethods() {
        TestData testData = new TestData();
        Test.startTest();
        ContentVersion cv=new Contentversion();
        cv.title='test';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Test Data');
        insert cv;
        System.runAs(testData.piUser) {
            PIR_HomepageController.deleteFile(cv.Id);
        }
        
        Test.stopTest();
    }

    @isTest
    static void testCreateScreener(){
        TestData testData = new TestData();
        PreScreener_Survey__c objScreener = new PreScreener_Survey__c(Link_to_Pre_screening__c ='https://surveytest.com',
                                                                     MRR__c = false,Prescreener__c = false,Primary__c=false,
                                                                     Survey_Name__c ='testScreenerNew',Study__c=testData.ctp.id);
        insert objScreener;
         System.runAs(testData.piUser) {
        test.startTest();
        PIR_HomepageController.createScreenerResponse(testData.pe.Id,'Pass','https://surveytest.com',JSON.serialize(objScreener));
        
         }
        test.stopTest(); 
        
    }
    @isTest
    static void testsetMRRStatus() {        
        TestData testData = new TestData();
        Test.startTest();
        PIR_HomepageController.setMRRStatus(testData.pe.Id,'Pass','https://surveytest.com');
        PIR_HomepageController.setMRRStatus(testData.pe.Id,'Fail','https://surveytest.com');
        PIR_HomepageController.setPreScreenerStatus(testData.pe.Id,'Pass','https://surveytest.com');
        PIR_HomepageController.setPreScreenerStatus(testData.pe.Id,'Fail','https://surveytest.com');
        
        try{
            PIR_HomepageController.setMRRStatus(testData.pe.Id,testData.pe.Id,testData.pe.Id);
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        try{
            PIR_HomepageController.setPreScreenerStatus('testData.pe.Id','testData.pe.Id','testData.pe.Id');
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        Test.stopTest();
    }
    
    @isTest
    static void testgetPEDataAdditionalMethod() {
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<Id> ctpIdList = new List<Id>();
        List<Id> ssIdList = new List<Id>();
        Test.startTest();
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id);
        ssIdList.add(ssList[0].Id);
        List<Participant_Enrollment__c> partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
        ];
        
        String filterlist = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":[],"activeInactive":"Inactive"}';
        String filterlistSiteNull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
         
        List<Clinical_Trial_Profile__c> ctpListnew = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpListnew[0].CommunityTemplate__c='Janssen';
        update ctpListnew;
        
        String filterlistJanseen = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpListnew[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        
       
        System.runAs(testData.piUser) {
            try{
                PIR_HomepageController.getListViewData(205,2,'Default',filterlist,true,true,'','',1);
                PIR_HomepageController.getListViewData(205,2,'Default',filterlist,false,false,'','',1);
                PIR_HomepageController.getStudyStudySiteDetails();
                PIR_HomepageController.fetchCurrentUserLanguage();
                PIR_HomepageController.getListViewData(1,-1,'Janssen',filterlist,true,true,'','',1);
                
            } catch(Exception ex) {
                
            }
        }
        Test.stopTest();        
    }
    @isTest
    static void testgetPEDataAdditionalMethod_1() {
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<Id> ctpIdList = new List<Id>();
        List<Id> ssIdList = new List<Id>();
        Test.startTest();
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id);
        ssIdList.add(ssList[0].Id);
        List<Participant_Enrollment__c> partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
        ];
        
        String filterlist = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":[],"activeInactive":"Inactive"}';
        String filterlistSiteNull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
         
        List<Clinical_Trial_Profile__c> ctpListnew = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpListnew[0].CommunityTemplate__c='Janssen';
        update ctpListnew;
        
        String filterlistJanseen = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpListnew[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        
       
        System.runAs(testData.piUser) {
            try{
                PIR_HomepageController.getListViewData(1,-1,'Janssen',filterlistSiteNull,true,true,'','',1);
                PIR_HomepageController.getListViewData(1,-1,'Janssen',filterlist,true,true,'test','',1);
                PIR_HomepageController.getListViewData(1,-1,'Janssen',filterlistJanseen,true,true,'test','',1); 
                PIR_HomepageController.getListViewData(1,-1,'Janssen',filterlistnull,true,true,'test','',1);
                PIR_HomepageController.getListViewData(1,-1,'Janssen',filterlistnull,true,true,'','',1);
                PIR_HomepageController.getListViewData(1,-1,'Default',filterlist,true,true,'','',1);
                
            } catch(Exception ex) {
                
            }
        }
        Test.stopTest();        
    }
    @isTest
    static void testgetPEDataAdditionalMethodNew() {
        TestData testData = new TestData();
        List<Clinical_Trial_Profile__c> ctpList = new List<Clinical_Trial_Profile__c>();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        List<Id> ctpIdList = new List<Id>();
        List<Id> ssIdList = new List<Id>();
        
        ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        ssList = [SELECT Id FROM Study_Site__c];
        
        ctpIdList.add(ctpList[0].Id);
        ssIdList.add(ssList[0].Id);
        List<Participant_Enrollment__c> partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c
            FROM Participant_Enrollment__c
        ];
        
        String filterlist = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        String filterlistnull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":[],"activeInactive":"Inactive"}';
        String filterlistSiteNull = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":[],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpList[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
         Test.startTest();
        List<Clinical_Trial_Profile__c> ctpListnew = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpListnew[0].CommunityTemplate__c='Janssen';
        update ctpListnew;
        
        String filterlistJanseen = '{"ethnicityList":["0- Prefer not to say","1- Hispanic/Latino","2- American Indian/Alaskan Native","7- Two or more races"],"highPriority":true,"initialVisit":"Initial Visit Scheduled","initialVisitStartDate":"2022-03-02","initialVisitEndDate":"2022-04-04","isDefault":false,"presetId":"","presetName":"","siteList":["'+ssList[0].id+'"],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":[],"studyList":["'+ctpListnew[0].id+'"],"activeInactive":"Inactive","ageFrom":"140","ageTo":"0","sex":"F","highRisk":"true","comorbidities":"true"}';
        
       
        System.runAs(testData.piUser) {
            try{
                
                PIR_HomepageController.getListViewData(1,-1,'Default',filterlist,true,true,'test','',1);
                PIR_HomepageController.getListViewData(1,-1,'Default',filterlistnull,true,true,'','',1);
                
            } catch(Exception ex) {
                
            }
        }
        Test.stopTest();        
    }
    @isTest 
    static void testgetPESiteStaffData() {
        TestData testData = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        testData.pe.Participant_Status__c = 'Pre-review Passed';
        
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
        Test.startTest();
        update testData.pe;
        Contact con = [
            SELECT Id, AccountId, MailingCountryCode, Participant_Opt_In_Status_SMS__c
            FROM Contact
            WHERE Id = :testData.participant.Contact__c
        ];
        //User u = [SELECT ContactId, Id, IsActive FROM User WHERE ContactId=:testData.participant.Contact__c];
        Study_Site__c ssn= [select id from Study_Site__c];
        List<Site_Staff__c> ssList = new List<Site_Staff__c>();
        for (Integer i = 1; i < 3; i++) {
            Site_Staff__c s = new Site_Staff__c(
                Email__c = 'sitestaff' + i + '@emil.com',
                Site_Contact__c = con.id,
                Study_Site__c=ssn.id,
                Delegate_Level__c = 'Level '+i,
                is_Invited__c = true
            );
            
            ssList.add(s);
        }
        TriggerHandlerExecutor.bypassHandler(
            SiteStaffTriggerHandler.AssignCommunitymodeAndTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            SiteStaffTriggerHandler.DuplicateSiteStaffHandler.class
        );
        
        
        insert ssList;
        
        Participant_Enrollment__c partEnroll = [
            SELECT Id, Participant__c, Show_Referring_Provider__c,Participant_Status__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ]; 
        partEnroll.Participant_Status__c='Received';
        update partEnroll;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = 'Eligibility Passed',
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = partEnroll.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
        
        System.runAs(testData.piUser){
            PIR_HomepageController.getPEData(testData.pe.Id);
            
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetStudyAccess() {
        TestData testData = new TestData();
        Set<Id> ctpIds = new Set<Id>();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        for(Clinical_Trial_Profile__c ctp: ctpList) {
            ctpIds.add(ctp.Id);
        }
        
        Test.startTest();
        System.runAs(testData.piUser){
            PIR_HomepageController.getStudyAccess(ctpIds);
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetStudyStudySite() {
        TestData testData = new TestData();
        Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        
        System.runAs(testData.piUser){
            PIR_HomepageController.getStudyStudySite();
            PIR_HomepageController.fetchPreset();
            PIR_HomepageController.getStudyStudySite();
        }
        Test.stopTest();
    }
	@isTest
    static void testGetStudyStudySite_New() {
        TestData testData = new TestData();
        Test.startTest();
        
        System.runAs(testData.piUser){
            PIR_HomepageController.getStudyStudySite();
        }
        Test.stopTest();
    }
    @isTest
    static void testgetAvailableStatuses() {
        TestData testData = new TestData();
        Set<Id> ctpIds = new Set<Id>();
         Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c,Initial_Visit_Required__c,Promote_to_SH__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].Initial_Visit_Required__c=false;
        ctpList[0].Promote_to_SH__c = false;
		ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        Terms_And_Conditions__c tc = new Terms_And_Conditions__c(T_C_Text__c = 'T&C');
        insert tc;
         List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        List<id> ssListID=new List<id> ();
        for(Study_Site__c ss:ssList ){
            ssListID.add(ss.id);
        }
        Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c(
            Terms_And_Conditions__c = tc.id,
            User__c = testData.piUser.id
        );
        insert tca;
        List<List_View_Status__mdt> lvs =[ SELECT Managed_in_SH__c, Initial_Visit__c, Available_Statuses__c
        FROM List_View_Status__mdt ];
       
        System.runAs(testData.piUser){
            PIR_HomepageController.getAvailableStatuses('Received',ctpList[0].Id,ssListID);
            PIR_HomepageController.getStudyStudySite();
            PIR_HomepageController.getStudyStudySiteDetails();
            PIR_HomepageController.getAvailableStatuses('Withdrew Consent',ctpList[0].Id,ssListID);
            PIR_HomepageController.getAvailableStatuses('Declined Consent',ctpList[0].Id,ssListID);
        }  
        Test.stopTest();
    }
    
    @isTest
    static void testbulkstatusDetail() {
        TestData testData = new TestData();
        Set<Id> ctpIds = new Set<Id>();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        
        
        Test.startTest();
        System.runAs(testData.piUser){
            PIR_HomepageController.bulkStatusReasonWrapper bs= new PIR_HomepageController.bulkStatusReasonWrapper();
            PIR_HomepageController.bulkstatusDetail('Received',ctpList[0].Id);
        }
        Test.stopTest();
    }
    @isTest
    static void testupdateParticipantStatus() {
        TestData testData = new TestData();
        List<Participant_Enrollment__c> pe = [SELECT Id,Participant_Contact__c FROM Participant_Enrollment__c WHERE Patient_ID__c=:'SomePatientId2'];
        List<Id> peList = new List<Id>{ pe[0].id };
            Set<Id> ctpIds = new Set<Id>();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        Study_Site__c studySite = [
            SELECT Id, Clinical_Trial_Profile__c
            FROM Study_Site__c
            
            LIMIT 1
        ];
        Incentive_Plan__c plan = new Incentive_Plan__c();
        plan.Plan_Name__c = 'Test IP1';
        plan.Clinical_Trial_Profile__c = studySite.Clinical_Trial_Profile__c;
        insert plan;
        Incentive_Plan_Task__c task = new Incentive_Plan_Task__c();
        task.Incentive_Task_Catalog__c = IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY;
        task.Incentive_Plan__c = plan.Id;
        task.Enabled__c = true;
        task.IQVIA_Supported__c = true;
        task.Points__c = 15;
        insert task;
        Study_Incentive_Plan__c sip = new Study_Incentive_Plan__c();
        sip.Incentive_Plan__c = plan.Id;
        sip.Study_Site__c = studySite.Id;
        insert sip;
        
        
        Test.startTest();
        System.runAs(testData.piUser){
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Received',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Contact Attempted',
                                                           True,
                                                           True,date.today());
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Unable to Reach',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Contact Attempted',
                                                           True,
                                                           True,date.today());
            
            try{
                PIR_HomepageController.updateParticipantStatus(peList,
                                                               ctpList[0].Id,
                                                               'Test Notes',
                                                               'Other',
                                                               ctpList[0].Id,
                                                               'Unable to Screen',
                                                               True,
                                                               True,date.today());
            }
            catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
            
        }
        Test.stopTest();
    }
	@isTest
    static void testupdateParticipantStatus_new() {
        TestData testData = new TestData();
        List<Participant_Enrollment__c> pe = [SELECT Id,Participant_Contact__c FROM Participant_Enrollment__c WHERE Patient_ID__c=:'SomePatientId2'];
        List<Id> peList = new List<Id>{ pe[0].id };
            Set<Id> ctpIds = new Set<Id>();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        Study_Site__c studySite = [
            SELECT Id, Clinical_Trial_Profile__c
            FROM Study_Site__c
            
            LIMIT 1
        ];
        Incentive_Plan__c plan = new Incentive_Plan__c();
        plan.Plan_Name__c = 'Test IP1';
        plan.Clinical_Trial_Profile__c = studySite.Clinical_Trial_Profile__c;
        insert plan;
        Incentive_Plan_Task__c task = new Incentive_Plan_Task__c();
        task.Incentive_Task_Catalog__c = IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY;
        task.Incentive_Plan__c = plan.Id;
        task.Enabled__c = true;
        task.IQVIA_Supported__c = true;
        task.Points__c = 15;
        insert task;
        Study_Incentive_Plan__c sip = new Study_Incentive_Plan__c();
        sip.Incentive_Plan__c = plan.Id;
        sip.Study_Site__c = studySite.Id;
        insert sip;
        
        
        Test.startTest();
        System.runAs(testData.piUser){
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           PEStatusState.PE_STATUS_DECLINED_FINAL_CONSENT,
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Contact Attempted',
                                                           True,
                                                           True,date.today());
            
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Sent to DCT',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Contact Attempted',
                                                           True,
                                                           True,date.today());
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'In Wash Out Period',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Contact Attempted',
                                                           True,
                                                           True,date.today());
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Declined Consent',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Declined Consent',
                                                           True,
                                                           True,date.today());
            
            
            
        }
        Test.stopTest();
    }
    @isTest
    static void testupdateParticipantStatus_new2() {
        TestData testData = new TestData();
        List<Participant_Enrollment__c> pe = [SELECT Id,Participant_Contact__c FROM Participant_Enrollment__c WHERE Patient_ID__c=:'SomePatientId2'];
        List<Id> peList = new List<Id>{ pe[0].id };
            Set<Id> ctpIds = new Set<Id>();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c limit 1];
        Study_Site__c studySite = [
            SELECT Id, Clinical_Trial_Profile__c
            FROM Study_Site__c
            
            LIMIT 1
        ];
        Incentive_Plan__c plan = new Incentive_Plan__c();
        plan.Plan_Name__c = 'Test IP1';
        plan.Clinical_Trial_Profile__c = studySite.Clinical_Trial_Profile__c;
        insert plan;
        Incentive_Plan_Task__c task = new Incentive_Plan_Task__c();
        task.Incentive_Task_Catalog__c = IncentiveTaskCatalog.INCENTIVE_TASK_MADE_CONTACT_ATTEMPT_WITHIN_1_DAY;
        task.Incentive_Plan__c = plan.Id;
        task.Enabled__c = true;
        task.IQVIA_Supported__c = true;
        task.Points__c = 15;
        insert task;
        Study_Incentive_Plan__c sip = new Study_Incentive_Plan__c();
        sip.Incentive_Plan__c = plan.Id;
        sip.Study_Site__c = studySite.Id;
        insert sip;
        
        
        Test.startTest();
        System.runAs(testData.piUser){
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Screening In Progress',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Ready To Screen',
                                                           True,
                                                           True,date.today());
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Contact Attempted',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Received',
                                                           True,
                                                           True,date.today());
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Unable to Screen',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Received',
                                                           True,
                                                           True,date.today());
            PIR_HomepageController.updateParticipantStatus(peList,
                                                           'Enrollment Success',
                                                           'Test Notes',
                                                           'Other',
                                                           ctpList[0].Id,
                                                           'Unable to Screen',
                                                           True,
                                                           True,date.today());
            
        }
        Test.stopTest();
    }
	
    @isTest
    static void testfetchPreset() {
        TestData testData = new TestData();
        Test.startTest();
        Set<Id> ctpIds = new Set<Id>();
        
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        
        System.runAs(testData.piUser){
            Preset_Filter__c presetFilter = new Preset_Filter__c(
                User_Preset__c = testData.piUser.id,
                Source__c='test',
                Status__c='test',
                Ethnicity__c='test,test',
                StudyId__c=ctpList[0].id,
                Study_Site_Id__c=ssList[0].id,
                Default_Preset__c=true,
                Community_Name__c='Default'
                
            );
            
            insert presetFilter;
            PIR_HomepageController.fetchPreset();
        }
        Test.stopTest();
    }
    @isTest
    static void testfetchPreset_new() {
        TestData testData = new TestData();
        Test.startTest();
        Set<Id> ctpIds = new Set<Id>();
        
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        
        System.runAs(testData.piUser){
            Preset_Filter__c presetFilter = new Preset_Filter__c(
                User_Preset__c = testData.piUser.id,
                Source__c='test',
                Status__c='test;test2;test3',
                Ethnicity__c='test,test',
                StudyId__c=ctpList[0].id,
                Study_Site_Id__c=ssList[0].id,
                Default_Preset__c=true,
                Community_Name__c='Default',
                StudyActive__c='Active'
            );
            
            insert presetFilter;
            PIR_HomepageController.fetchPreset();
            presetFilter.StudyActive__c='Inactive';
            update presetFilter;
            PIR_HomepageController.fetchPreset();
        }
        Test.stopTest();
    }
    @isTest
    static void testcreatePreset() {
        TestData testData = new TestData();
		Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        Preset_Filter__c presetFilter = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=true
            
        );
        
        insert presetFilter;
        Preset_Filter__c presetFilter1 = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=false
            
        );
        
        insert presetFilter1;
        Preset_Filter__c pf=[select id, User_Preset__c from Preset_Filter__c where  Default_Preset__c=true];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        String filterlist = '{"ethnicityList":[],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[""],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Pre-review Failed","Unable to Reach","Contacted - Not Suitable","Eligibility Failed","Declined Consent","Unable to Screen","Withdrew Consent","Screening Failed","Withdrew Consent After Screening","Enrollment Failed","Randomization Failed","Declined Final Consent"],"studyList":[""],"activeInactive":"Inactive"}';
        
        
        System.runAs(testData.piUser){ 
            string cretePre= PIR_HomepageController.createPreset('{"ethnicityList":[],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"'+presetFilter.id+'","presetName":"test","siteList":[""],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Pre-review Failed","Unable to Reach","Contacted - Not Suitable","Eligibility Failed","Declined Consent","Unable to Screen","Withdrew Consent","Screening Failed","Withdrew Consent After Screening","Enrollment Failed","Randomization Failed","Declined Final Consent"],"studyList":[""],"activeInactive":"Inactive"}',true);
            PIR_HomepageController.createPreset('{"ethnicityList":[],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"testnew","siteList":[""],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Pre-review Failed","Unable to Reach","Contacted - Not Suitable","Eligibility Failed","Declined Consent","Unable to Screen","Withdrew Consent","Screening Failed","Withdrew Consent After Screening","Enrollment Failed","Randomization Failed","Declined Final Consent"],"studyList":[""],"activeInactive":"Inactive"}',false);
            string deletepre =PIR_HomepageController.deletePreset('{"ethnicityList":[],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":true,"presetId":"'+presetFilter.id+'","presetName":"test","siteList":[""],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Pre-review Failed","Unable to Reach","Contacted - Not Suitable","Eligibility Failed","Declined Consent","Unable to Screen","Withdrew Consent","Screening Failed","Withdrew Consent After Screening","Enrollment Failed","Randomization Failed","Declined Final Consent"],"studyList":[""],"activeInactive":"Inactive"}');
            System.assertEquals('deleted',deletepre);
            System.assertEquals('success',cretePre);
        }
        Test.stopTest();
    }
     @isTest
    static void testcreatePresetNew() {
        TestData testData = new TestData();
		Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        Preset_Filter__c presetFilter = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=true,
             Community_Name__c='Default'
            
        );
        
        insert presetFilter;
        Preset_Filter__c presetFilter1 = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=false,
             Community_Name__c='Default'
            
        );
        
        insert presetFilter1;
        Preset_Filter__c presetFilter2 = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=false,
             Community_Name__c='Default'
            
        );
        
        insert presetFilter2;
        Preset_Filter__c presetFilter3 = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=false,
             Community_Name__c='Default'
            
        );
        
        insert presetFilter3;
         Preset_Filter__c presetFilter4 = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=false,
              Community_Name__c='Default'
            
        );
        
        insert presetFilter4;
        List<Preset_Filter__c> pf=[select id, User_Preset__c from Preset_Filter__c ];
        
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        
        System.runAs(testData.piUser){
            PIR_HomepageController.createPreset('{"ethnicityList":[],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"testnew","siteList":[""],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Pre-review Failed","Unable to Reach","Contacted - Not Suitable","Eligibility Failed","Declined Consent","Unable to Screen","Withdrew Consent","Screening Failed","Withdrew Consent After Screening","Enrollment Failed","Randomization Failed","Declined Final Consent"],"studyList":[""],"activeInactive":"Inactive"}',false);
            
        }
        Test.stopTest();
    }
    @isTest
    static void testsetselectedFilterasDefault() {
        TestData testData = new TestData();
		Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        List<Study_Site__c> ssList = [SELECT Id FROM Study_Site__c limit 1];
        Preset_Filter__c presetFilter = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=true,
            Community_Name__c='Default'
            
        );
        
        insert presetFilter;
        Preset_Filter__c presetFilter1 = new Preset_Filter__c(
            User_Preset__c = testData.piUser.id,
            Source__c='test',
            Status__c='test',
            StudyId__c=ctpList[0].id,
            Study_Site_Id__c=ssList[0].id,
            Default_Preset__c=false,
            Community_Name__c='Default'
            
        );
        
        insert presetFilter1;
        
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        
        System.runAs(testData.piUser){
            PIR_HomepageController.setselectedFilterasDefault(presetFilter1.id);
            PIR_HomepageController.setselectedFilterasDefault('no preset');
            PIR_HomepageController.fetchPreset();
            string cretePre= PIR_HomepageController.createPreset('{"ethnicityList":[],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"'+presetFilter.id+'","presetName":"","siteList":[""],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Pre-review Failed","Unable to Reach","Contacted - Not Suitable","Eligibility Failed","Declined Consent","Unable to Screen","Withdrew Consent","Screening Failed","Withdrew Consent After Screening","Enrollment Failed","Randomization Failed","Declined Final Consent"],"studyList":[""],"activeInactive":"Inactive"}',true);
            PIR_HomepageController.createPreset('{"ethnicityList":[],"highPriority":false,"initialVisit":"Initial Visit Scheduled","isDefault":false,"presetId":"","presetName":"","siteList":[""],"source":["Referring Provider","Principal Investigator","Digital Recruitment"],"status":["Pre-review Failed","Unable to Reach","Contacted - Not Suitable","Eligibility Failed","Declined Consent","Unable to Screen","Withdrew Consent","Screening Failed","Withdrew Consent After Screening","Enrollment Failed","Randomization Failed","Declined Final Consent"],"studyList":[""],"activeInactive":"Inactive"}',false);
            //System.assertEquals('duplicateName',cretePre);
            
        }
        Test.stopTest();
    }
    
    
}