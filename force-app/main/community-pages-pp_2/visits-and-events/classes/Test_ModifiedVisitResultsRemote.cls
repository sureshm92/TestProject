/**
 * Created by rushikesh.kadam on 27.03.2023.
 */
@IsTest
private class Test_ModifiedVisitResultsRemote {
    @TestSetup
    static void setup() {
        TriggerHandlerExecutor.bypassHandler(
            ContactReferralNetworkTriggerHandler.SyncContactInterestedSites.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTherapeuticAreaTriggerHandler.SyncContactInterestedTopics.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreateStatusHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void getInitData_test() {
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 0;
        update testData.ctp;

        List<Visit_Result_Type_Sharing__c> visitResultTypeSharingsList = new List<Visit_Result_Type_Sharing__c>();
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'Calcium',
                Sharing_Countries__c = 'US'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'New_York_carcinoma',
                Sharing_Countries__c = 'US'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'Weight',
                Sharing_Countries__c = 'US'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'BUN',
                Sharing_Countries__c = 'US'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'RBC_Count',
                Sharing_Countries__c = 'US'
            )
        );

        insert visitResultTypeSharingsList;

        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        testData.updatePEStatusEnrollmentSuccess();

        Test.startTest();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
            )
        );
        insert patientVisits;

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'BUN'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 12,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Hematocrit'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 133,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'RBC_Count'
            )
        );
        insert visitResults;

        System.runAs(testData.participantUser) {
            ModifiedVisitResultsService.ModifiedInitDataWrapper wrapper = ModifiedVisitResultsRemote.getInitDataModified(
                0,
                patientVisits.get(0).Id
            );
            System.assert(wrapper != null);
        }
        Test.stopTest();
    }

    @IsTest
    static void getInitDataTrialComplete_test() {
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 0;
        update testData.ctp;

        Visit_Result_Type_Sharing__c vrts = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Calcium',
            Sharing_Countries__c = 'US'
        );
        insert vrts;

        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        testData.pe.Participant_Contact__r.Visit_Results_OptIn__c = 'Vitals;Labs;Biomarkers';
        update testData.pe;

        Test.startTest();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 2
            )
        );
        insert patientVisits;

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'BUN'
            )
        );
        Id vitalRecTypeId = SchemaUtil.getRecordTypeIdByName(
            VisitResultSharingService.VITAL_RECORDTYPE,
            Visit_Result__c.getSObjectType()
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 133,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Weight',
                RecordTypeId = vitalRecTypeId
            )
        );
        insert visitResults;

        System.runAs(testData.participantUser) {
            ModifiedVisitResultsService.ModifiedInitDataWrapper wrapper = ModifiedVisitResultsRemote.getInitDataModified(
                0,
                patientVisits.get(0).Id
            );
            System.assert(wrapper != null);
        }
        Test.stopTest();
    }

    @IsTest
    static void getInitDataNegative_test() {
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Visit_Result_Type_Sharing__c vrts = new Visit_Result_Type_Sharing__c(
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Include_Countries__c = true,
            Type__c = 'Calcium',
            Sharing_Countries__c = 'US'
        );
        insert vrts;

        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        Test.startTest();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
            )
        );
        insert patientVisits;

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'BUN'
            )
        );
        insert visitResults;

        System.runAs(testData.participantUser) {
            ModifiedVisitResultsService.ModifiedInitDataWrapper wrapper = ModifiedVisitResultsRemote.getInitDataModified(
                0,
                patientVisits.get(0).Id
            );
            System.assert(wrapper != null);
            System.assertEquals(false, wrapper.isVisitResultsAvailable);
        }
        Test.stopTest();
    }

    @IsTest
    static void switchToggleRemoteToggleOn_test() {
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();

        Participant_Enrollment__c currentPE = [
            SELECT Id, Participant_Contact__r.Visit_Results_OptIn__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];

        Test.startTest();
        System.runAs(testData.participantUser) {
            ModifiedVisitResultsRemote.modifiedSwitchToggleRemote('Vitals', true);
            ModifiedVisitResultsRemote.modifiedSwitchToggleRemote('Biomarkers', true);
        }
        Test.stopTest();

        currentPE = [
            SELECT Id, Participant_Contact__r.Visit_Results_OptIn__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        System.assertEquals('Biomarkers', currentPE.Participant_Contact__r.Visit_Results_OptIn__c);
    }

    @IsTest
    static void switchToggleRemoteToggleOff_test() {
        TestData testData = new TestData();
        testData.updatePEStatusEnrollmentSuccess();

        Participant_Enrollment__c currentPE = [
            SELECT Id, Participant_Contact__r.Visit_Results_OptIn__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        currentPE.Participant_Contact__r.Visit_Results_OptIn__c = 'Vitals;Labs;Biomarkers';
        update currentPE;

        Test.startTest();
        System.runAs(testData.participantUser) {
            ModifiedVisitResultsRemote.modifiedSwitchToggleRemote('Vitals', false);
            ModifiedVisitResultsRemote.modifiedSwitchToggleRemote('Biomarkers', false);
        }
        Test.stopTest();

        currentPE = [
            SELECT Id, Participant_Contact__r.Visit_Results_OptIn__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];
        System.assertEquals('Labs', currentPE.Participant_Contact__r.Visit_Results_OptIn__c);
    }

    @IsTest
    static void ppVisitResultsWrapper_test() {
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 0;
        update testData.ctp;

        List<Visit_Result_Type_Sharing__c> visitResultTypeSharingsList = new List<Visit_Result_Type_Sharing__c>();
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'Calcium',
                Sharing_Countries__c = 'US'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'New_York_carcinoma',
                Sharing_Countries__c = 'US',
                Custom_Tooltip__c = ' Custom topptip text'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'Triglycerides',
                Sharing_Countries__c = 'US'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'Hematocrit',
                Sharing_Countries__c = 'US'
            )
        );
        visitResultTypeSharingsList.add(
            new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'RBC_Count',
                Sharing_Countries__c = 'US'
            )
        );

        insert visitResultTypeSharingsList;

        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        List<Visit__c> visits = new List<Visit__c>();
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        testData.updatePEStatusEnrollmentSuccess();

        Test.startTest();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
            )
        );
        insert patientVisits;
        Id labRecordTypeId = Schema.SObjectType.Visit_Result__c.getRecordTypeInfosByName()
            .get('Lab')
            .getRecordTypeId();
        Id bioMarkerRecordTypeId = Schema.SObjectType.Visit_Result__c.getRecordTypeInfosByName()
            .get('Biomarker')
            .getRecordTypeId();

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium',
                RecordTypeId = labRecordTypeId,
                Measurement__c = 'MG/DL'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'New_York_carcinoma',
                RecordTypeId = bioMarkerRecordTypeId
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 12,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Hematocrit',
                RecordTypeId = labRecordTypeId
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 133,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Triglycerides',
                RecordTypeId = labRecordTypeId
            )
        );
        insert visitResults;

        System.runAs(testData.participantUser) {
            ModifiedVisitResultsService.ModifiedInitDataWrapper wrapper = ModifiedVisitResultsRemote.getInitDataModified(
                0,
                patientVisits.get(0).Id
            );
            List<ModifiedVisitResultsService.ModifiedVisitResultsContainer> reswrapper = ModifiedVisitResultsRemote.getVisitResultsWrapperModified(
                testData.ctp.Id,
                patientVisits.get(0).Id,
                'US',
                wrapper.visitResultWithSubTypesCTP,
                'Labs'
            );
            System.assert(reswrapper != null);

            List<ModifiedVisitResultsService.ModifiedVisitResultsContainer> reswrapper1 = ModifiedVisitResultsRemote.getVisitResultsWrapperModified(
                testData.ctp.Id,
                patientVisits.get(0).Id,
                'US',
                wrapper.visitResultWithSubTypesCTP,
                'Biomarkers'
            );
            System.assert(reswrapper1 != null);
        }
        ModifiedVisitResultsService.ModifiedInitDataWrapper wrap = ModifiedVisitResultsRemote.getInitDataForVisitResultsModified();

        Test.stopTest();
    }
}