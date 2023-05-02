@isTest
public with sharing class PIR_ParticipantDetailControllerTest {
    @TestSetup
    static void init(){
        TestData.loadTestData(); 
    }
    @isTest
    static void testgetVisitPlansLVList(){
        Test.startTest();
        
        TestData testData = new TestData();
        byPassTriggersMethod();
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;  
        List<Clinical_Trial_Profile__c> clinicalTrialProfiles = new List<Clinical_Trial_Profile__c>();
        clinicalTrialProfiles.add(
            (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
                Clinical_Trial_Profile__c.getSObjectType(),
                new Map<String, Object>{
                    'Study_Title__c' => 'CTP 1',
                        'Protocol_ID__c' => 'CTP 1',
                        'Study_Code_Name__c' => 'CTP 1',
                        'NCT_Number__c' => 'NCT00000001',
                        
                        'Synch_with_TMDH__c' => true
                        }
            )
        ); 
        insert clinicalTrialProfiles;
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        
        Account singleAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert singleAccount;
        Study_Site__c ss = new Study_Site__c();
        ss.Name = 'Sample';
        ss.Principal_Investigator__c = delegate.Id;
        ss.Clinical_Trial_Profile__c = clinicalTrialProfiles[0].Id;
        ss.Site__c = singleAccount.Id;
        ss.Study_Site_Key__c = 'sample';
        insert ss;
        StudySiteVisitPlan__c studyVisitPlan = new StudySiteVisitPlan__c();
        studyVisitPlan.Study_Site__c = ss.Id;
        studyVisitPlan.Visit_Plan__c = vp.Id;
        insert studyVIsitPlan;
        PIR_ParticipantDetailController.getVisitPlansLVList(ss.Id);
        Test.stopTest();
    }
    
    @isTest
    static void testGetParticipantData(){
        TestData testData = new TestData();
        
        String delegateString = '{ "Id": "","Participant_Delegate__c": "","Participant_Delegate__r": {"First_Name__c": "test1","Last_Name__c": "test","Email__c": "test2@test.com","Phone__c": "12312312","Birth_Year__c": "2000","Attestation__c": true}}';
        Test.startTest();
        Map<String,sObject> dataMap = PIR_ParticipantDetailController.getParticipantData(testData.pe.Id);
        System.assertEquals(true,dataMap.containsKey('pe'));
        PIR_ParticipantDetailController.CountyrStateInfo countryInfo = new PIR_ParticipantDetailController.CountyrStateInfo();        
        PIR_ParticipantDetailController.getCnData();
        System.assert(countryInfo.stateMap != null);
        System.assert(countryInfo.adultAgeByCountryStateCode != null);
        //Boolean isSavePrDetails = PIR_ParticipantDetailController.doSaveParticipantDetails(testData.pe,delegateString,false, false,true,'insertDelegate');
        //System.assertEquals(true,isSavePrDetails);
        Test.stopTest();
    }
    
    @isTest
    static void testDoSaveParticipantDetails_peUpdated(){
        TestData testData = new TestData();
         byPassTriggersMethod();
        Participant_Enrollment__c perRec = [
            SELECT
            Id,
            Name,
            External_Key__c,
            Participant_Contact__c,
            Participant_Contact__r.Id,
            Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
            Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
            Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
            Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
            Participant_Contact__r.IQVIA_Artificial_Voice_Consent__c,
            Participant_Contact__r.IQVIA_Assisted_Dialing_Consent__c,
            Participant_Contact__r.IQVIA_Pre_recorded_Voice_Consent__c,
            Participant_Status__c,
            Participant_Contact__r.Visit_Results_OptIn__c,
            Initial_visit_scheduled_date__c,
            Initial_visit_occurred_date__c,
            Initial_visit_scheduled_time__c,
            Initial_visit_occurred_flag__c,
            Initial_visit_scheduled_flag__c,
            Screening_ID__c,
            Participant__c,
            Medical_Record_Review_Completed_Date__c,
            Study_Site__r.Principal_Investigator__c,
            Study_Site__r.Principal_Investigator__r.Name,
            Study_Site__r.Principal_Investigator__r.Title,
            Permit_Mail_Email_contact_for_this_study__c,
            Permit_SMS_Text_for_this_study__c,
            Permit_Voice_Text_contact_for_this_study__c,
            Study_Direct_Mail_Consent__c,
            MRN_Id__c,
            Participant__r.Email__c,
            Participant__r.First_Name__c,
            Participant__r.Last_Name__c,
            Participant__r.Mailing_Zip_Postal_Code__c,
            Participant__r.Mailing_State__c,
            Participant__r.Mailing_Country__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        perRec.Permit_Mail_Email_contact_for_this_study__c = true;
        perRec.Permit_SMS_Text_for_this_study__c = false;
        perRec.MRN_Id__c = 'mrn123';
        update perRec;
        String delegateString = '{ "Id": "","Participant_Delegate__c": "","Participant_Delegate__r": {"First_Name__c": "test1","Last_Name__c": "test","Email__c": "test2@test.com","Phone__c": "12312312","Birth_Year__c": "2000","Attestation__c": true}}';
        String consentJSON = '{ "Study_Email_Consent": true,"Study_info_storage_consent": true,"Study_Phone_Consent":true,"Study_SMS_Consent":true }';
        Test.startTest();
         Boolean isSavePrDetails = PIR_ParticipantDetailController.doSaveParticipantDetails(perRec,delegateString,true, true,true,false,'insertDelegate','',false,consentJSON,'');
        System.assertEquals(true,isSavePrDetails);
        Test.stopTest();
    }
    
      @isTest
    static void testgetDupDelegateConsent(){
        TestData testData = new TestData();
         byPassTriggersMethod();
         Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;    
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Email__c = 'delegate@somemail.com',
            Contact__c = delegate.Id
        );
        insert p;
        Participant_Enrollment__c perRec = [
            SELECT
            Id,
            Name,
            External_Key__c,
            Participant_Contact__c,
            Participant_Contact__r.Id,
            Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
            Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
            Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
            Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
            Participant_Contact__r.IQVIA_Artificial_Voice_Consent__c,
            Participant_Contact__r.IQVIA_Assisted_Dialing_Consent__c,
            Participant_Contact__r.IQVIA_Pre_recorded_Voice_Consent__c,
            Participant_Status__c,
            Participant_Contact__r.Visit_Results_OptIn__c,
            Initial_visit_scheduled_date__c,
            Initial_visit_occurred_date__c,
            Initial_visit_scheduled_time__c,
            Initial_visit_occurred_flag__c,
            Initial_visit_scheduled_flag__c,
            Screening_ID__c,
            Participant__c,
            Medical_Record_Review_Completed_Date__c,
            Study_Site__r.Principal_Investigator__c,
            Study_Site__r.Principal_Investigator__r.Name,
            Study_Site__r.Principal_Investigator__r.Title,
            Permit_Mail_Email_contact_for_this_study__c,
            Permit_SMS_Text_for_this_study__c,
            Permit_Voice_Text_contact_for_this_study__c,
            Study_Direct_Mail_Consent__c,
            MRN_Id__c,
            Participant__r.Email__c,
            Participant__r.First_Name__c,
            Participant__r.Last_Name__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        perRec.Permit_Mail_Email_contact_for_this_study__c = true;
        perRec.Permit_SMS_Text_for_this_study__c = false;
        perRec.MRN_Id__c = 'mrn123';
        update perRec;
         Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant,
            Participant_Delegate__c = p.Id,
            Participant_Delegate__r = p,
            Primary_Delegate__c = true
        );
        
        insert patientDelegate;
        Patient_Delegate_Enrollment__c objPder = new Patient_Delegate_Enrollment__c(Patient_Delegate__c =patientDelegate.id,
                                                                                   Participant_Enrollment__c =perRec.id,
                                                                                   Study_info_storage_consent__c = true,
                                                                                   Study_Email_Consent__c = true,Study_Phone_Consent__c = true
                                                                                   ,Study_SMS_Consent__c = true);
        insert objPder; 
        
        Boolean isalreadyConsnentedForNonUs = PIR_ParticipantDetailController.getDupDelegateConsent(perRec.id,p.Id,false);
        System.assertEquals(true,isalreadyConsnentedForNonUs);
        Test.startTest();
         Boolean isalreadyConsneted = PIR_ParticipantDetailController.getDupDelegateConsent(perRec.id,p.Id,true);
        System.assertEquals(true,isalreadyConsneted);
        Test.stopTest();
    }
    
     @isTest
    static void testgetDupDelegateExistingConsent(){
        TestData testData = new TestData();
         byPassTriggersMethod();
         Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;    
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Email__c = 'delegate@somemail.com',
            Contact__c = delegate.Id
        );
        insert p;
        Participant_Enrollment__c perRec = [
            SELECT
            Id,
            Name,
            External_Key__c,
            Participant_Contact__c,
            Participant_Contact__r.Id,
            Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
            Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
            Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
            Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
            Participant_Contact__r.IQVIA_Artificial_Voice_Consent__c,
            Participant_Contact__r.IQVIA_Assisted_Dialing_Consent__c,
            Participant_Contact__r.IQVIA_Pre_recorded_Voice_Consent__c,
            Participant_Status__c,
            Participant_Contact__r.Visit_Results_OptIn__c,
            Initial_visit_scheduled_date__c,
            Initial_visit_occurred_date__c,
            Initial_visit_scheduled_time__c,
            Initial_visit_occurred_flag__c,
            Initial_visit_scheduled_flag__c,
            Screening_ID__c,
            Participant__c,
            Medical_Record_Review_Completed_Date__c,
            Study_Site__r.Principal_Investigator__c,
            Study_Site__r.Principal_Investigator__r.Name,
            Study_Site__r.Principal_Investigator__r.Title,
            Permit_Mail_Email_contact_for_this_study__c,
            Permit_SMS_Text_for_this_study__c,
            Permit_Voice_Text_contact_for_this_study__c,
            Study_Direct_Mail_Consent__c,
            MRN_Id__c,
            Participant__r.Email__c,
            Participant__r.First_Name__c,
            Participant__r.Last_Name__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        perRec.Permit_Mail_Email_contact_for_this_study__c = true;
        perRec.Permit_SMS_Text_for_this_study__c = false;
        perRec.MRN_Id__c = 'mrn123';
        update perRec;
         Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant,
            Participant_Delegate__c = p.Id,
            Participant_Delegate__r = p,
            Primary_Delegate__c = true
        );
        
        insert patientDelegate;
        Patient_Delegate_Enrollment__c objPder = new Patient_Delegate_Enrollment__c(Patient_Delegate__c =patientDelegate.id,
                                                                                   Participant_Enrollment__c =perRec.id,
                                                                                   Study_info_storage_consent__c = true,
                                                                                   Study_Email_Consent__c = true,Study_Phone_Consent__c = true
                                                                                   ,Study_SMS_Consent__c = true,Primary_Delegate__c = true);
        insert objPder; 
        
        Boolean isConsentedForNonUs = PIR_ParticipantDetailController.getDupDelegateExistingConsent(perRec.id,p.Id,false);
        
        System.assertEquals(true,isConsentedForNonUs);
        Test.startTest();
         Boolean isalreadyConsneted = PIR_ParticipantDetailController.getDupDelegateExistingConsent(perRec.id,p.Id,
                                                                                        true);
         System.assertEquals(true,isalreadyConsneted);
        Boolean isPDERConsneted = PIR_ParticipantDetailController.getPDERConsent(perRec.id);
        System.assertEquals(true,isPDERConsneted);
        Test.stopTest();
    }
    
      @isTest
    static void testupdateDelContact(){
        TestData testData = new TestData();
         byPassTriggersMethod();
         Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true,
             Participant_Opt_In_Status_SMS__c = true
        );
        insert delegate;    
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Email__c = 'delegate@somemail.com',
            Contact__c = delegate.Id
        );
        insert p;
        Participant_Enrollment__c perRec = [
            SELECT
            Id,
            Name,
            External_Key__c,
            Participant_Contact__c,
            Participant_Contact__r.Id,
            Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
            Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
            Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
            Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
            Participant_Contact__r.IQVIA_Artificial_Voice_Consent__c,
            Participant_Contact__r.IQVIA_Assisted_Dialing_Consent__c,
            Participant_Contact__r.IQVIA_Pre_recorded_Voice_Consent__c,
            Participant_Status__c,
            Participant_Contact__r.Visit_Results_OptIn__c,
            Initial_visit_scheduled_date__c,
            Initial_visit_occurred_date__c,
            Initial_visit_scheduled_time__c,
            Initial_visit_occurred_flag__c,
            Initial_visit_scheduled_flag__c,
            Screening_ID__c,
            Participant__c,
            Medical_Record_Review_Completed_Date__c,
            Study_Site__r.Principal_Investigator__c,
            Study_Site__r.Principal_Investigator__r.Name,
            Study_Site__r.Principal_Investigator__r.Title,
            Permit_Mail_Email_contact_for_this_study__c,
            Permit_SMS_Text_for_this_study__c,
            Permit_Voice_Text_contact_for_this_study__c,
            Study_Direct_Mail_Consent__c,
            MRN_Id__c,
            Participant__r.Email__c,
            Participant__r.First_Name__c,
            Participant__r.Last_Name__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        perRec.Permit_Mail_Email_contact_for_this_study__c = true;
        perRec.Permit_SMS_Text_for_this_study__c = false;
        perRec.MRN_Id__c = 'mrn123';
        update perRec;
         Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant,
            Participant_Delegate__c = p.Id,
            Participant_Delegate__r = p,
            Primary_Delegate__c = true
        );
        
        insert patientDelegate; 
        
        Test.startTest();
         PIR_ParticipantDetailController.updateDelContact(delegate.id,patientDelegate,perRec);   
        Test.stopTest();
    }
    
    @isTest
    static void testDoSaveParticipantDetails() {
        TestData testData = new TestData();
        byPassTriggersMethod();
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateEnrolTriggerHandler.CreateReactivatedNotification.class
            );
         TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateReactivatedNotification.class
            );
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;    
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Email__c = 'delegate@somemail.com',
            Contact__c = delegate.Id
        );
        insert p;
          Participant_Enrollment__c pe = [
            SELECT
            Id,
            Name,
            External_Key__c,
            Participant_Contact__c,
            Participant_Contact__r.Id,
            Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
            Participant_Contact__r.Participant_Opt_In_Status_SMS__c,
            Participant_Contact__r.Participant_Phone_Opt_In_Permit_Phone__c,
            Participant_Contact__r.IQVIA_Direct_Mail_Consent__c,
            Participant_Contact__r.IQVIA_Artificial_Voice_Consent__c,
            Participant_Contact__r.IQVIA_Assisted_Dialing_Consent__c,
            Participant_Contact__r.IQVIA_Pre_recorded_Voice_Consent__c,
            Participant_Status__c,
            Participant_Contact__r.Visit_Results_OptIn__c,
            Initial_visit_scheduled_date__c,
            Initial_visit_occurred_date__c,
            Initial_visit_scheduled_time__c,
            Initial_visit_occurred_flag__c,
            Initial_visit_scheduled_flag__c,
            Screening_ID__c,
            Participant__c,
            Medical_Record_Review_Completed_Date__c,
            Study_Site__r.Principal_Investigator__c,
            Study_Site__r.Principal_Investigator__r.Name,
            Study_Site__r.Principal_Investigator__r.Title,
            Permit_Mail_Email_contact_for_this_study__c,
            Permit_SMS_Text_for_this_study__c,
            Permit_Voice_Text_contact_for_this_study__c,
            Study_Direct_Mail_Consent__c,
            MRN_Id__c,
            Participant__r.Email__c,
            Participant__r.First_Name__c,
            Participant__r.Last_Name__c,
            Participant__r.Mailing_Zip_Postal_Code__c,
            Participant__r.Mailing_State__c,
            Participant__r.Mailing_Country__c
            FROM Participant_Enrollment__c
            LIMIT 1
        ];
        
        pe.Participant__r.Email__c = null;
        update pe;
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = testData.participant.Id,
            Participant__r = testData.participant,
            Participant_Delegate__c = p.Id,
            Participant_Delegate__r = p,
            Primary_Delegate__c = true
        );
        
        String delegateIdString = '{ "Id": "'+patientDelegate.Id+'","Contact__c":"'+delegate.Id+'","Participant_Delegate__c": "'+patientDelegate.Participant_Delegate__r.Id+'","Participant_Delegate__r": {"Id":"'+patientDelegate.Participant_Delegate__r.Id+'","Contact__c":"'+delegate.Id+'","First_Name__c": "test1","Last_Name__c": "'+patientDelegate.Participant_Delegate__r.Last_Name__c+'","Email__c": "'+patientDelegate.Participant_Delegate__r.Email__c+'","Phone__c": "12312312","Birth_Year__c": "2000","Attestation__c": true}}';
         String delegateIdString1 = '{ "Id": "'+patientDelegate.Id+'","Contact__c":"'+delegate.Id+'","Participant_Delegate__c": "'+pe.Id+'","Participant_Delegate__r": {"Id":"'+patientDelegate.Participant_Delegate__r.Id+'","Contact__c":"'+delegate.Id+'","First_Name__c": "test1","Last_Name__c": "'+patientDelegate.Participant_Delegate__r.Last_Name__c+'","Email__c": "'+patientDelegate.Participant_Delegate__r.Email__c+'","Phone__c": "12312312","Birth_Year__c": "2000","Attestation__c": true}}';
         String consentJSON = '{ "Study_Email_Consent": true,"Study_info_storage_consent": true,"Study_Phone_Consent":true,"Study_SMS_Consent":true }';
       
        Boolean isSavePrDetails = PIR_ParticipantDetailController.doSaveParticipantDetails(testData.pe,delegateIdString,false, false,true,false,'updateDeligate','',true,consentJSON,'');
          Boolean isSavePrDetails1 = PIR_ParticipantDetailController.doSaveParticipantDetails(testData.pe,delegateIdString,false, false,true,false,'updateDeligate','',false,consentJSON,'');
          Test.startTest();
          Boolean isSavePrDetails4 = PIR_ParticipantDetailController.doSaveParticipantDetails(testData.pe,delegateIdString1,false, false,true,false,'updateDeligate','',true,consentJSON,'');
        
          Boolean isSavePrDetails2 = PIR_ParticipantDetailController.doSaveParticipantDetails(pe,delegateIdString,false, false,true,true,'updateDeligate','',false,consentJSON,'');
      
          Boolean isSavePrDetails3 = PIR_ParticipantDetailController.doSaveParticipantDetails(pe,delegateIdString,false, false,false,true,'updateDeligate','',false,consentJSON,'');
        System.assertEquals(true,isSavePrDetails);
        PIR_ParticipantDetailController.doSaveParticipantDetails(testData.pe,delegateIdString,false, false,true,false,'updateParticipant','',false,consentJSON,'');
        try{
            PIR_ParticipantDetailController.doSaveParticipantDetails(testData.pe,delegateIdString,false, false,true,true,'','',false,consentJSON,'');
        }catch(Exception ex){}
        String delegateDeleteString = '{ "Id": "'+patientDelegate.Id+'","Participant_Delegate__c": "'+patientDelegate.Participant_Delegate__r.Id+'","Participant_Delegate__r": {"Id":"'+patientDelegate.Participant_Delegate__r.Id+'","First_Name__c": "","Last_Name__c": "'+patientDelegate.Participant_Delegate__r.Last_Name__c+'","Email__c": "'+patientDelegate.Participant_Delegate__r.Email__c+'","Phone__c": "12312312","Birth_Year__c": "2000","Attestation__c": true}}';
        try{
        PIR_ParticipantDetailController.doSaveParticipantDetails(testData.pe,delegateDeleteString,false, false,true,false,'','',false,consentJSON,'');
        }
        catch(Exception ex) {
            System.assertEquals(ex.getMessage(),'Script-thrown exception' );
        }
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
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantDetailsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
        );
    }
}