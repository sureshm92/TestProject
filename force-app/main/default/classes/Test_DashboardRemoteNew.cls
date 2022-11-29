@isTest(seeAllData=false)
private class Test_DashboardRemoteNew {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void HCPTest() {
        TestData testDataInst = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            //DashboardRemoteNew.getInitData(CommunityService.USER_MODE_HCP, CommunityTemplateService.TEMPLATE_DEFAULT, testDataInst.ss.Principal_Investigator__c, testDataInst.piContact.Id,testDataInst.ctp.Id,'Init');
            DashboardRemoteNew.getInitData(
                CommunityService.USER_MODE_HCP,
                null,
                null,
                null,
                null,
                null
            );
            DashboardRemoteNew.getParticipantData(
                CommunityService.USER_MODE_HCP,
                null,
                testDataInst.participant.Id,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            // Added
            //DashboardRemoteNew.prepareAwaitingContactList(CommunityService.USER_MODE_HCP,testDataInst.ss.Principal_Investigator__c,testDataInst.piContact.Id,testDataInst.ctp.Id);
            DashboardRemoteNew.prepareAwaitingContactList(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_HCP,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareDataForFunnelChart(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareHCPEList(testDataInst.piContact.Id, testDataInst.ctp.Id);
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            //DashboardRemoteNew.getPEEnrollmentsByPI(testDataInst.piContact.Id);
            DashboardRemoteNew.getPIName(testDataInst.piContact.Id);
            DashboardRemoteNew.getStudyName(testDataInst.ctp.Id);
            DashboardRemoteNew.getCurrentStudySitesCount(testDataInst.ctp.Id);
            DashboardRemoteNew.getStudySiteDetails(testDataInst.piContact.Id, testDataInst.ctp.Id);

            List<Participant_Enrollment__c> pe = [
                SELECT
                    Id,
                    Name,
                    External_Key__c,
                    Participant_Contact__c,
                    Participant_Status__c,
                    Participant_Contact__r.Visit_Results_OptIn__c,
                    Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                    Initial_visit_scheduled_date__c,
                    Initial_visit_occurred_date__c,
                    Initial_visit_scheduled_time__c,
                    Initial_visit_occurred_flag__c,
                    Initial_visit_scheduled_flag__c,
                    Screening_ID__c,
                    Participant__c,
                    Medical_Record_Review_Completed_Date__c,
                    Study_Site__c,
                    Referral_Source__c,
                    Study_Site__r.Name,
                    Study_Site__r.Principal_Investigator__c,
                    Study_Site__r.Principal_Investigator__r.Name,
                    Study_Site__r.Principal_Investigator__r.Title,
                    Study_Site__r.Clinical_Trial_Profile__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Participant__r.Mailing_Country_Code__c,
                    Participant__r.Mailing_Country__c,
                    Participant__r.Emancipation_in_progress__c,
                    HCP__r.HCP_Contact__c,
                    HCP__r.Status__c,
                    PI_Contact__c,
                    Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
                    Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
                    Clinical_Trial_Profile__r.Link_to_Pre_screening__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c,
                    Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
                    Study_Site__r.Override_PI_Referral_Status__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c,
                    Study_Hub_Log__c,
                    Study_Hub_Log__r.Response_Status_Code__c,
                    Clinical_Trial_Profile__r.Promote_to_SH__c,
                    Study_Site__r.Study_Site_Type__c,
                    Informed_Consent__c
                FROM Participant_Enrollment__c
                WHERE Id = :testDataInst.pe.Id
            ];
            DashboardRemoteNew.preparePEList(new List<Participant_Enrollment__c>{pe[0]}, CommunityService.USER_MODE_HCP, testDataInst.Participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PITest() {
        TestData testDataInst = new TestData();
        TestData.createHCPEWaitingAcceptance();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            DashboardRemoteNew.getInitData(
                CommunityService.USER_MODE_PI,
                CommunityTemplateService.TEMPLATE_DEFAULT,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                'Init'
            );
            DashboardRemoteNew.getParticipantData(
                CommunityService.USER_MODE_PI,
                null,
                testDataInst.participant.Id,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareAwaitingContactList(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareDataForFunnelChart(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareHCPEList(testDataInst.piContact.Id, testDataInst.ctp.Id);
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            //DashboardRemoteNew.getPEEnrollmentsByPI(testDataInst.piContact.Id);
            DashboardRemoteNew.getPIName(testDataInst.piContact.Id);
            DashboardRemoteNew.getStudyName(testDataInst.ctp.Id);
            DashboardRemoteNew.getCurrentStudySitesCount(testDataInst.ctp.Id);
            DashboardRemoteNew.getStudySiteDetails(testDataInst.piContact.Id, testDataInst.ctp.Id);

            List<Participant_Enrollment__c> pe = [
                SELECT
                    Id,
                    Name,
                    External_Key__c,
                    Participant_Contact__c,
                    Participant_Status__c,
                    Participant_Contact__r.Visit_Results_OptIn__c,
                    Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                    Initial_visit_scheduled_date__c,
                    Initial_visit_occurred_date__c,
                    Initial_visit_scheduled_time__c,
                    Initial_visit_occurred_flag__c,
                    Initial_visit_scheduled_flag__c,
                    Screening_ID__c,
                    Participant__c,
                    Medical_Record_Review_Completed_Date__c,
                    Study_Site__c,
                    Referral_Source__c,
                    Study_Site__r.Name,
                    Study_Site__r.Principal_Investigator__c,
                    Study_Site__r.Principal_Investigator__r.Name,
                    Study_Site__r.Principal_Investigator__r.Title,
                    Study_Site__r.Clinical_Trial_Profile__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Study_Code_Name__c,
                    Participant__r.Mailing_Country_Code__c,
                    Participant__r.Mailing_Country__c,
                    Participant__r.Emancipation_in_progress__c,
                    HCP__r.HCP_Contact__c,
                    HCP__r.Status__c,
                    PI_Contact__c,
                    Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
                    Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
                    Clinical_Trial_Profile__r.Link_to_Pre_screening__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Terms_And_Conditions_ID__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Override_Recruitment_Status__c,
                    Study_Site__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Participant_Workflow_Final_Step__c,
                    Study_Site__r.Override_PI_Referral_Status__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Link_to_Medical_Record_Review__c,
                    Study_Site__r.Clinical_Trial_Profile__r.Link_to_Pre_screening__c,
                    Study_Hub_Log__c,
                    Study_Hub_Log__r.Response_Status_Code__c,
                    Clinical_Trial_Profile__r.Promote_to_SH__c,
                    Study_Site__r.Study_Site_Type__c,
                    Informed_Consent__c
                FROM Participant_Enrollment__c
                WHERE Id = :testDataInst.pe.Id
            ];
            DashboardRemoteNew.preparePEList(new List<Participant_Enrollment__c>{pe[0]}, CommunityService.USER_MODE_PI, testDataInst.Participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIContactAttemptedTest() {
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_CONTACT_ATTEMPTED);
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            DashboardRemoteNew.getInitData(
                CommunityService.USER_MODE_PI,
                CommunityTemplateService.TEMPLATE_DEFAULT,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                'Init'
            );
            DashboardRemoteNew.prepareAwaitingContactList(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareDataForFunnelChart(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareHCPEList(testDataInst.piContact.Id, testDataInst.ctp.Id);
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            // DashboardRemoteNew.getPEEnrollmentsByPI(testDataInst.piContact.Id);
            DashboardRemoteNew.getPIName(testDataInst.piContact.Id);
            DashboardRemoteNew.getStudyName(testDataInst.ctp.Id);
            DashboardRemoteNew.getCurrentStudySitesCount(testDataInst.ctp.Id);
            DashboardRemoteNew.getStudySiteDetails(testDataInst.piContact.Id, testDataInst.ctp.Id);
            // DashboardRemoteNew.preparePEList(new List<Participant_Enrollment__c>{testDataInst.pe}, CommunityService.USER_MODE_PI, testDataInst.Participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIDelegateTest() {
        TestData.createPIDelegateUser();
        TestData testDataInst = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piDelUser) {
            //DashboardRemoteNew.getInitData(CommunityService.USER_MODE_PI, CommunityTemplateService.TEMPLATE_DEFAULT, testDataInst.ss.Principal_Investigator__c,testDataInst.ss.Principal_Investigator__c,testDataInst.ctp.Id,'Init');
            DashboardRemoteNew.getParticipantData(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.participant.Id,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareAwaitingContactList(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareDataForFunnelChart(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareHCPEList(testDataInst.piContact.Id, testDataInst.ctp.Id);
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            // DashboardRemoteNew.getPEEnrollmentsByPI(testDataInst.piContact.Id);
            DashboardRemoteNew.getPIName(testDataInst.piContact.Id);
            DashboardRemoteNew.getStudyName(testDataInst.ctp.Id);
            DashboardRemoteNew.getCurrentStudySitesCount(testDataInst.ctp.Id);
            DashboardRemoteNew.getStudySiteDetails(testDataInst.piContact.Id, testDataInst.ctp.Id);
            // DashboardRemoteNew.preparePEList(new List<Participant_Enrollment__c>{testDataInst.pe}, CommunityService.USER_MODE_PI, testDataInst.Participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIJanssenTest() {
        TestData.createPIDelegateUser();
        TestData testDataInst = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piDelUser) {
            // DashboardRemoteNew.getInitData(CommunityService.USER_MODE_PI, CommunityTemplateService.TEMPLATE_DEFAULT, testDataInst.ss.Principal_Investigator__c,testDataInst.ss.Principal_Investigator__c,testDataInst.ctp.Id,'Init');
            DashboardRemoteNew.getParticipantData(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.participant.Id,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareDataForFunnelChart(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareHCPEList(testDataInst.piContact.Id, testDataInst.ctp.Id);
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.getPIName(testDataInst.piContact.Id);
            DashboardRemoteNew.getPEEnrollmentsByPI(testDataInst.Participant.Id);
            DashboardRemoteNew.getInvitedDetails(testDataInst.Participant.Id);
            DashboardRemoteNew.getStudyName(testDataInst.ctp.Id);
            DashboardRemoteNew.getCurrentStudySitesCount(testDataInst.ctp.Id);
            DashboardRemoteNew.getStudySiteDetails(testDataInst.piContact.Id, testDataInst.ctp.Id);
            //DashboardRemoteNew.preparePEList(new List<Participant_Enrollment__c>{testDataInst.pe}, CommunityService.USER_MODE_PI, testDataInst.Participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PINullInitTest() {
        TestData testDataInst = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTherapeuticAreaTriggerHandler.SyncContactInterestedTopics.class
        );

        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);

        Test.startTest();
        System.runAs(testDataInst.piUser) {
            DashboardRemoteNew.getInitData(
                CommunityService.USER_MODE_PI,
                CommunityTemplateService.TEMPLATE_DEFAULT,
                null,
                null,
                testDataInst.ctp.Id,
                'Init'
            );
            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareDataForFunnelChart(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.prepareHCPEList(testDataInst.piContact.Id, testDataInst.ctp.Id);
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
            DashboardRemoteNew.getPIName(testDataInst.piContact.Id);
            DashboardRemoteNew.getPEEnrollmentsByPI(testDataInst.Participant.Id);
            DashboardRemoteNew.getStudyName(testDataInst.ctp.Id);
            DashboardRemoteNew.getCurrentStudySitesCount(testDataInst.ctp.Id);
            DashboardRemoteNew.getStudySiteDetails(testDataInst.piContact.Id, testDataInst.ctp.Id);
            //DashboardRemoteNew.preparePEList(new List<Participant_Enrollment__c>{testDataInst.pe}, CommunityService.USER_MODE_PI, testDataInst.Participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void getContactedParticipantsDataTest() {
        TestData testDataInst = new TestData();
        TestData.createHCPEWaitingAcceptance();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);

        List<Participant_Enrollment_Status_History__c> peHistry = [
            SELECT Id FROM Participant_Enrollment_Status_History__c WHERE Status__c = :PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED LIMIT 1
        ];
        peHistry[0].Date__c = system.Today().addDays(-5);
        update peHistry;
        
        Test.startTest();

        System.runAs(testDataInst.piUser) {
            
            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            peHistry[0].Date__c = system.Today().addDays(-8);
            update peHistry;

            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            peHistry[0].Date__c = system.Today().addDays(-12);
            update peHistry;

            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            peHistry[0].Date__c = system.Today().addDays(-17);
            update peHistry;

            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            peHistry[0].Date__c = system.Today().addDays(-25);
            update peHistry;

            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            TriggerHandlerExecutor.bypassHandler(
                ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class
            );

            testDataInst.ctp.Initial_Visit_Required__c = false;
            update testDataInst.ctp;

            DashboardRemoteNew.getContactedParticipantsData(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void prepareWaitingListTest() {
        TestData testDataInst = new TestData();
        TestData.createHCPEWaitingAcceptance();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
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
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);

        List<Participant_Enrollment_Status_History__c> peHistry = [
            SELECT Id FROM Participant_Enrollment_Status_History__c WHERE Status__c = :PEStatusState.PE_STATUS_RECEIVED LIMIT 1
        ];
        peHistry[0].Date__c = system.Today().addDays(-5);
        update peHistry;
        
        Test.startTest();

        System.runAs(testDataInst.piUser) {
            
            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            peHistry[0].Date__c = system.Today().addDays(-8);
            update peHistry;

            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            peHistry[0].Date__c = system.Today().addDays(-12);
            update peHistry;

            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );

            peHistry[0].Date__c = system.Today().addDays(-25);
            update peHistry;

            DashboardRemoteNew.prepareWaitingList(
                CommunityService.USER_MODE_PI,
                testDataInst.ss.Principal_Investigator__c,
                testDataInst.piContact.Id,
                testDataInst.ctp.Id
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void prepareAwaitingContactListTest() {
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_CONTACT_ATTEMPTED);

        Test.startTest();

        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = testDataInst.piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = testDataInst.ss.Id,
            is_Invited__c = true
        );
        insert siteStaff;
        
        List<Participant__c> partList = [SELECT Id FROM Participant__c LIMIT 1];
        partList[0].Contact__c = testDataInst.piContact.Id;
        partList[0].Middle_Name__c = 'Test middle';
        partList[0].Suffix__c = 'Mr';
        update partList[0];

        System.runAs(testDataInst.piUser) {
            
            DashboardRemoteNew.getPIName(testDataInst.piContact.Id);

            DashboardRemoteNew.prepareAwaitingContactList(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void prepareAwaitingContactListTest2() {
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_CONTACT_ATTEMPTED);

        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509,
                BillingCountry = 'United States'
            );
        insert studySiteAccount;

        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = testDataInst.piContact.Id,
            Clinical_Trial_Profile__c = testDataInst.ctp.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SS1',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code',
            Enable_for_Call_Center_Support__c = true
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

        parList.Participant_Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
        update parList;

        Test.startTest();

        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = testDataInst.piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = testDataInst.ss.Id,
            is_Invited__c = true
        );
        insert siteStaff;

        System.runAs(testDataInst.piUser) {
            
            DashboardRemoteNew.prepareAwaitingContactList(
                testDataInst.piContact.Id,
                testDataInst.ctp.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
        }
        Test.stopTest();
    }
}