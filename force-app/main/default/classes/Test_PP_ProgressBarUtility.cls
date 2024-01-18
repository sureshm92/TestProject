@IsTest
public class Test_PP_ProgressBarUtility {
    @TestSetup
    static void init() {
         TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.createPIUserOrSendNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.afterInsert.class
        );
		TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
		);
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.afterInsert.class
        );
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            TriggerHandlerExecutor.contextExecuteHandler.class            
        );
          TriggerHandlerExecutor.execute(
        HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class
    );
          TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotifications.class
                );
         TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.afterInsert.class
                );
         TriggerHandlerExecutor.execute(
        ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
    );
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void baseHCPTest() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Visit_Schedule_Is_Available__c = true;
        t1.Study_External_URL__c = 'https://test.com';
        insert t1;
        
        Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;

        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId78887',
            Clinical_Trial_Profile__c = t1.Id,
            Clinical_Trial_Profile__r = t1,
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral',
            Screening_ID__c = 'PESCR9991',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert parList;
       	parList.Participant_Status__c = 'Enrollment Success';
        update parList;
  
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan HCP');
        insert vp;
        
        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;
        
        Patient_Visit__c pt = new Patient_Visit__c(
                Participant_Enrollment__c = parList.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            );
        insert pt;

       // PP_ProgressBarUtility.generateProgressBar(parList.Id);
    }
    
    @IsTest
    static void programBarWithStatus() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Visit_Schedule_Is_Available__c = true;
        t1.Study_External_URL__c = 'https://test.com';
        t1.Is_Program__c = true;
        insert t1;
        
        Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;

        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId78887',
            Clinical_Trial_Profile__c = t1.Id,
            Clinical_Trial_Profile__r = t1,
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral',
            Screening_ID__c = 'PESCR9991',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert parList;
       	parList.Participant_Status__c = 'Enrollment Success';
        update parList;
         Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            ParticipantEnrollment__c = parList.Id,
            Status__c = 'Successfully Contacted' 
        );
        insert pehistory1;
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        
        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;
        
        Patient_Visit__c pt = new Patient_Visit__c(
                Participant_Enrollment__c = parList.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            );
            insert pt;
       // PP_ProgressBarUtility.generateProgressBar(parList.Id);
        PP_ProgressBarUtility.updatePatientVisit(pt.Id+'');
        PP_ProgressBarUtility.showProgress(parList.Id); 
    }
    @IsTest
    static void programBarWithStatustestert() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Visit_Schedule_Is_Available__c = true;
        t1.Status_Milestone_Available__c = true;
        t1.Study_External_URL__c = 'https://test.com';
        t1.Is_Program__c = true;
        insert t1;
        
        Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;

        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId78887',
            Clinical_Trial_Profile__c = t1.Id,
            Clinical_Trial_Profile__r = t1,
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral',
            Screening_ID__c = 'PESCR9991',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert parList;
       	parList.Participant_Status__c = 'Participant No Show';
        update parList;
         Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            ParticipantEnrollment__c = parList.Id,
            Status__c = 'Successfully Contacted' 
        );
        insert pehistory1;
       
             
        PP_ProgressBarUtility.showProgress(parList.Id);
    }
    @IsTest
    static void statusProgramBarintrial() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Status_Milestone_Available__c = true;
        t1.Study_External_URL__c = 'https://test.com';
        t1.Is_Program__c = false;
        t1.Initial_Visit_Required__c= false;
        insert t1;
        
        Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;

        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Initial_visit_scheduled_flag__c = true,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId78887',
            Clinical_Trial_Profile__c = t1.Id,
            Clinical_Trial_Profile__r = t1,
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral ',
            Screening_ID__c = 'PESCR9991',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert parList;
       	parList.Participant_Status__c = 'Enrollment Success';
        update parList;
        Study_status_description_motivation__c stg = new Study_status_description_motivation__c();
        stg.Status_Name__c = 'Enrollment Success';
        stg.Study__c = t1.Id;
        stg.Status_Description__c = 'Description';
        stg.Status_Motivational_Message__c = 'Motivational message';
        stg.Status_Developer_Name__c='Enrollment1';
        insert stg;
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;
        
        Patient_Visit__c pt = new Patient_Visit__c(
                Participant_Enrollment__c = parList.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            );
            insert pt;
 
        //PP_ProgressBarUtility.generateProgressBar(parList.Id);
        PP_ProgressBarUtility.parentWrapper pw = new PP_ProgressBarUtility.parentWrapper();
        pw = PP_ProgressBarUtility.generateBarForInTrial(parList,pw,parList.Id);
    }
      @IsTest
    static void statusProgramBar() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Status_Milestone_Available__c = true;
        t1.Study_External_URL__c = 'https://test.com';
        t1.Is_Program__c = false;
        t1.Initial_Visit_Required__c= false;
        insert t1;
        
        Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;

        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Initial_visit_scheduled_flag__c = true,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId78887',
            Clinical_Trial_Profile__c = t1.Id,
            Clinical_Trial_Profile__r = t1,
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral ',
            Screening_ID__c = 'PESCR9991',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert parList;
       	parList.Participant_Status__c = 'Initial Visit';
        update parList;
         Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            ParticipantEnrollment__c = parList.Id,
            Status__c = 'Successfully Contacted' 
        );
        insert pehistory1;
        Study_status_description_motivation__c stg = new Study_status_description_motivation__c();
        stg.Status_Name__c = '';
        stg.Study__c = t1.Id;
        stg.Status_Description__c = 'Description';
        stg.Status_Motivational_Message__c = 'Motivational message';
        stg.Status_Developer_Name__c='Enrollment1';
        insert stg;
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;
        
        Patient_Visit__c pt = new Patient_Visit__c(
                Participant_Enrollment__c = parList.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            );
            insert pt;
 
        PP_ProgressBarUtility.generateProgressBar(parList.Id);
    }
       @IsTest
    static void statusProgramBartestyes() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Status_Milestone_Available__c = true;
        t1.Study_External_URL__c = 'https://test.com';
        t1.Is_Program__c = true;
        t1.Initial_Visit_Required__c= false;
        insert t1;
        
        Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;

        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Initial_visit_scheduled_flag__c = true,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId78887',
            Clinical_Trial_Profile__c = t1.Id,
            Clinical_Trial_Profile__r = t1,
            Referral_Source__c = 'HCP',
            Source_Type__c = 'Referring Provider',
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral ',
            Screening_ID__c = 'PESCR9991',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert parList;
       	parList.Participant_Status__c = 'Enrollment Success';
        update parList;
        Study_status_description_motivation__c stg = new Study_status_description_motivation__c();
        stg.Status_Name__c = 'Enrollment Success';
        stg.Study__c = t1.Id;
        stg.Status_Description__c = 'Description';
        stg.Status_Motivational_Message__c = 'Motivational message';
        stg.Status_Developer_Name__c='Enrollment1';
        insert stg;
        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;
        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;
        
        Patient_Visit__c pt = new Patient_Visit__c(
                Participant_Enrollment__c = parList.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            );
            insert pt;
 
        PP_ProgressBarUtility.parentWrapper pw = new PP_ProgressBarUtility.parentWrapper();
        pw = PP_ProgressBarUtility.generateVisitData(parList.Id,pw,true,false,parList);
    }
    @IsTest
    static void statusProgramBartest() {
        Clinical_Trial_Profile__c t1 = (Clinical_Trial_Profile__c) TestDataFactory.getSObject(
            Clinical_Trial_Profile__c.getSObjectType()
        );
        t1.NCT_Number__c = 'NCT00000000';
        t1.Protocol_ID__c = 'NCT00000000';
        t1.Status_Milestone_Available__c = true;
        t1.Study_External_URL__c = 'https://test.com';
        t1.Is_Program__c = false;
        t1.Initial_Visit_Required__c= true;
        insert t1;
        
        Account piAccount = new Account(Name = 'PI Account');
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = 'pi@emil.com',
            AccountId = piAccount.Id
        );
        insert piContact;
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountryCode = 'US'
        );
        insert studySiteAccount;

        
        Study_Site__c studySite = new Study_Site__c(
            Primary_Key_ePR__c = 'tt123456789_US_123',
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = t1.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = '123'
        );
        insert studySite;
        Time myTime = Time.newInstance(1, 2, 3, 0);
        Participant_Enrollment__c parList = new Participant_Enrollment__c(
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            Initial_visit_scheduled_date__c = date.today(),
            Initial_visit_scheduled_time__c = myTime,
            Initial_visit_scheduled_flag__c = true,
            Initial_visit_occurred_flag__c = true,
            Informed_Consent__c = true,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId78887',
            Clinical_Trial_Profile__c = t1.Id,
            Clinical_Trial_Profile__r = t1,
            HighRisk_Indicator__c = 'Yes',
            High_Priority__c=false,
            Participant_Status__c = 'Pending Referral ',
            Screening_ID__c = 'PESCR9991',
            Birth_Month__c='04',
            YOB__c='2000'
        );
        insert parList;
        parList.Participant_Status__c = 'Initial Visit';
        update parList;
        Study_status_description_motivation__c stg = new Study_status_description_motivation__c();
        stg.Status_Name__c = '';
        stg.Study__c = t1.Id;
        stg.Status_Description__c = 'Description';
        stg.Status_Motivational_Message__c = 'Motivational message';
        stg.Status_Developer_Name__c='Enrollment1';
        insert stg;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = date.today(),
             Status__c = 'Successfully Contacted' ,
            ParticipantEnrollment__c = parList.Id
           
        );
        insert pehistory1;
 
        PP_ProgressBarUtility.parentWrapper pw = new PP_ProgressBarUtility.parentWrapper();
        pw= PP_ProgressBarUtility.generateBarForPreTrial(parList,pw,parList.Id);
    }
}