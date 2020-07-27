/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_Dashboard {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void HCPTest() {
        TestData testDataInst = new TestData();
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_HCP, null,null,null,null,null);
            DashboardRemote.getParticipantData(CommunityService.USER_MODE_HCP, null,testDataInst.participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PITest() {
        TestData testDataInst = new TestData();
        TestData.createHCPEWaitingAcceptance();
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, null, null, testDataInst.piContact.Id,testDataInst.ctp.Id,null);
            DashboardRemote.getParticipantData(CommunityService.USER_MODE_PI, null,testDataInst.participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIContactAttemptedTest() {
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_CONTACT_ATTEMPTED);
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, null,null,testDataInst.piContact.Id,testDataInst.ctp.Id,null);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIDelegateTest() {
        TestData.createPIDelegateUser();
        TestData testDataInst = new TestData();
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piDelUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, null, testDataInst.ss.Principal_Investigator__c,testDataInst.ss.Principal_Investigator__c,testDataInst.ctp.Id,null);
            DashboardRemote.getParticipantData(CommunityService.USER_MODE_PI, testDataInst.ss.Principal_Investigator__c,testDataInst.participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIJanssenTest() {
        TestData.createPIDelegateUser();
        TestData testDataInst = new TestData();
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piDelUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, 'Janssen', testDataInst.ss.Principal_Investigator__c,testDataInst.ss.Principal_Investigator__c,testDataInst.ctp.Id,null);
            DashboardRemote.getParticipantData(CommunityService.USER_MODE_PI, testDataInst.ss.Principal_Investigator__c,testDataInst.participant.Id);
        }
        Test.stopTest();
    }
}