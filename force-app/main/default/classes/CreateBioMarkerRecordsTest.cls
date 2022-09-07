@isTest
public with sharing class CreateBioMarkerRecordsTest {
    @testSetup
    public static void testData() {
        TestData.loadTestData();        
    }

    @istest
    public static void testCreateBiomarker_PERNotExisting() {
        List<Integration_Biomarker__c> biomarkRecList = new List<Integration_Biomarker__c>();
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContentDocumentLinkTriggerHandler.class
        );
        Datetime myDate = Datetime.newInstance(2022, 12, 1, 12, 30, 2);
        Integration_Biomarker__c biomarkRec = new Integration_Biomarker__c();
        biomarkRec.Data_JSON1__c = '{ "referral_id": "123-4560","referral_language": "en US", "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"}';
        biomarkRec.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true}';
        biomarkRec.Assessed_On__c = myDate;
        biomarkRec.BiomarkerVendorReachoutStatus__c = 'Success';
        biomarkRec.Vendor_Source__c = 'KI';
        biomarkRecList.add(biomarkRec);
        insert biomarkRecList;

        test.startTest();
        CreateBiomarkerRecords.saveBiomarkerRecords(biomarkRecList);
        Integration_Biomarker__c biomarkRecord = [SELECT Id,Biomarker_Error__c FROM Integration_Biomarker__c WHERE Id=:biomarkRecList[0].Id];
        System.assertEquals('PER Record is Invalid',biomarkRecord.Biomarker_Error__c);
        test.stopTest();
    }

    @istest
    public static void testCreateBiomarker_PERExisting() {
        
        List<Participant_Enrollment__c> objpart = [SELECT ID,Referral_ID__c FROM Participant_Enrollment__c 
            WHERE  Screening_ID__c = 'PESCR3' OR Screening_ID__c = 'PESCR5' limit 2];
        
        objpart[0].Referral_ID__c = '1234-34';
        objpart[1].Referral_ID__c = '3456-34';

        byPassTriggersMethod();
        Test.StartTest();
        update objpart;
        
        
        List<Integration_Biomarker__c> biomarkRecList = new List<Integration_Biomarker__c>();
        Datetime myDate = Datetime.newInstance(2022, 12, 1, 12, 30, 2);
        Integration_Biomarker__c biomarkRec = new Integration_Biomarker__c();
        biomarkRec.Data_JSON1__c = '{ "referral_id": "1234-34","referral_language": "en US", "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"}';
        biomarkRec.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true}';
        biomarkRec.Assessed_On__c = myDate;
        biomarkRec.BiomarkerVendorReachoutStatus__c = 'Success';
        biomarkRec.Vendor_Source__c = 'KI';
        biomarkRec.Completed__c = false;
        biomarkRecList.add(biomarkRec);
        insert biomarkRecList;
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion);        
        
        insert contentVersionList;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('documents:'+documents);
        
        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = biomarkRecList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);

        ContentDocumentLink cdl1 = New ContentDocumentLink();
        cdl1.LinkedEntityId = biomarkRecList[0].id;
        cdl1.ContentDocumentId = documents[1].Id;
        cdl1.shareType = 'V';
        cdl1.Visibility = 'AllUsers';
        contentDocList.add(cdl1);
        
        insert contentDocList;

        
        CreateBiomarkerRecords rec = new CreateBiomarkerRecords();
        CreateBiomarkerRecords.saveBiomarkerRecords(biomarkRecList);
        List<RH_Biomarker__c> biomarkerList = [SELECT Id FROM RH_Biomarker__c];
        Test.StopTest();
        List<Biomarker_Result__c> biomarkerResultList = [SELECT Id FROM Biomarker_Result__c ];
        System.assertEquals(1,biomarkerList.size());
        System.assertEquals(4,biomarkerResultList.size());
       
    }

    @istest
    public static void testCreateBiomarker_Exception() {
        List<Integration_Biomarker__c> biomarkRecList = new List<Integration_Biomarker__c>();
        Datetime myDate = Datetime.newInstance(2022, 12, 1, 12, 30, 2);
        Integration_Biomarker__c biomarkRec = new Integration_Biomarker__c();
        biomarkRec.Data_JSON1__c = '{ "referral_id": "1234-34","referral_language": 12, "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"';
        biomarkRec.Data_JSON2__c = '{}';
        biomarkRec.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true}';
        biomarkRec.Result_JSON2__c = '{}';
        biomarkRec.Assessed_On__c = myDate;
        biomarkRec.BiomarkerVendorReachoutStatus__c = 'true';
        biomarkRec.Vendor_Source__c = 'KI';
        biomarkRec.Completed__c = true;
        biomarkRecList.add(biomarkRec);
        Integration_Biomarker__c biomarkRec1 = new Integration_Biomarker__c();
        biomarkRec1.Data_JSON1__c = '{ "referral_id": "1234-34","referral_language": 12, "referral_country": "Germany", "site_id": "1235", "protocol_id": "1235", "referral_auto_dialer_consent": "2021-01-12T00:00:00+00:00", "user_feedback": "76"}';
        biomarkRec1.Result_JSON1__c = '{"cdr_sob": 0.5, "hc_mci_d_traditional": "dementia", "hc_mci_ml_based": "no-mci", "referral": true';
        biomarkRec1.Result_JSON2__c = '{}';
        biomarkRec1.Assessed_On__c = myDate;
        biomarkRec1.BiomarkerVendorReachoutStatus__c = 'true';
        biomarkRec1.Vendor_Source__c = 'KI';
        biomarkRec1.Completed__c = true;
        biomarkRecList.add(biomarkRec1);
        insert biomarkRecList;
        Test.StartTest();
        try{
            CreateBiomarkerRecords.saveBiomarkerRecords(biomarkRecList);
        }catch(Exception ex) {
            List<IntegrationLog__c> logList = [SELECT Id FROM IntegrationLog__c];
            System.assertEquals(1,logList.size());
        }
        Test.StopTest();
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
            ContentDocumentLinkTriggerHandler.class
        );
    }
}