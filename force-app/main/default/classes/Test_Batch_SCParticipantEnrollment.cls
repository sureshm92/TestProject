@IsTest
public class Test_Batch_SCParticipantEnrollment {

    @TestSetup
    static void init(){
        
        TestData.loadTestData();  
    }
    @isTest static void testSCParticipantEnroll() {
        
        TestData testData1 = new TestData();
        byPassTriggersMethod();
        
        Id ctpId=[select id from Clinical_Trial_Profile__c limit 1].Id;
        
        Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'delegate@somemail.com',
            AccountId = testData1.participant.Contact__r.AccountId,
            Current_Participant_Enrollment__c = testData1.pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
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

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Participant__c = testData1.participant.Id,
            Participant_Delegate__c = p.Id
        );
        
        insert patientDelegate;
        
        Participant_Enrollment__c pe = new Participant_Enrollment__c(
        
            Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
            Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
            PI_Contact__c = testData1.piContact.Id,
            Participant_Contact__c = delegate.Id,
            Study_Site__c = testData1.ss.Id,
            Patient_ID__c = 'SomePatientId1',
            Referral_Source__c = 'HCP',
            Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
            Participant__c = p.Id,
            Screening_ID__c = 'PESCR1',
            Invited_To_PP_Date__c = system.now(),
            Participant_Status_Last_Changed_Date__c=system.now()
        );
        
        Study_Closure__c stClosure= new Study_Closure__c(Clinical_Trial_Profile_Id__c=ctpId,Clinical_Trial_Profile_Name__c='Test');
        insert stClosure;
        Test.startTest();
        Batch_SCParticipantEnrollment pEnroll = new Batch_SCParticipantEnrollment();
        pEnroll.studyClosureId=ctpId;
        Id batchId = Database.executeBatch(pEnroll);
        Test.stopTest();
    }
    @isTest static void testSCParticipantEnroll_DeleteStudy() {
        Id ctpId=[select id from Clinical_Trial_Profile__c limit 1].Id;
        Study_Closure__c stClosure= new Study_Closure__c(Clinical_Trial_Profile_Id__c=ctpId,Clinical_Trial_Profile_Name__c='Test');
        insert stClosure;
        Test.startTest();
        Batch_SCParticipantEnrollment pEnroll = new Batch_SCParticipantEnrollment();
        pEnroll.studyClosureId=ctpId;
        pEnroll.isStudyToDelete=true;
        Id batchId = Database.executeBatch(pEnroll);
        Test.stopTest();
    }
     /*@isTest static void testSCParticipantEnroll_NoStudyClosureRec() {
        Id ctpId=[select id from Clinical_Trial_Profile__c limit 1].Id;
        Test.startTest();
         try{
             Batch_SCParticipantEnrollment pEnroll = new Batch_SCParticipantEnrollment();
             pEnroll.studyClosureId=ctpId;
             Id batchId = Database.executeBatch(pEnroll);
         }catch(Exception ex){
            System.assertEquals('Please check the studyClosureId and created studyClosure record.', ex.getMessage());
         }
        Test.stopTest();
    }*/
    
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
    }
}