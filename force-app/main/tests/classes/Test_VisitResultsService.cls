/**
 * Created by dmytro.fedchyshyn on 05.08.2019.
 */

@IsTest
private class Test_VisitResultsService {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1', '2', '3');

        List<Participant_Enrollment__c> peList = [
            SELECT Id, External_Key__c
            FROM Participant_Enrollment__c
            WHERE External_Key__c = '1~2~3'
            LIMIT 1
        ];

        Patient_Visit__c visit = new Patient_Visit__c();
        visit.Name = 'New Visit';
        visit.Completed_Date__c = Date.today();
        visit.Participant_Enrollment__c = peList[0].Id;
        visit.SDH_Key__c = '1~2~3' + 'New Visit' + Date.today();
        insert visit;
        Date visitDate5 = Date.today() + 2;
        List<Integration_VisitResult__c> ivrList = new List<Integration_VisitResult__c>();
        Integration_VisitResult__c externalVisitResult1 = new Integration_VisitResult__c();
        externalVisitResult1.USUBJID__c = '1~2~3';
        externalVisitResult1.VISIT__c = 'New Visit';
        externalVisitResult1.VSDTC__c = Date.today();
        externalVisitResult1.TESTCD__c = 'BUNCC';
        externalVisitResult1.Vital_or_Lab__c = 'Vital';
        externalVisitResult1.STNRHI__c = 10;
        externalVisitResult1.STUDYID__c = '10';
        externalVisitResult1.IsDeletedInSDH__c = 'N';
        externalVisitResult1.VISITNUM__c = 1;

        Integration_VisitResult__c externalVisitResult2 = new Integration_VisitResult__c();
        externalVisitResult2.USUBJID__c = '1~2~3';
        externalVisitResult2.VISIT__c = 'New Visit';
        externalVisitResult2.VSDTC__c = Date.today();
        externalVisitResult2.TESTCD__c = 'NYESO';
        externalVisitResult2.Vital_or_Lab__c = 'Vital';
        externalVisitResult2.STNRHI__c = 11;
        externalVisitResult2.STUDYID__c = '10';
        externalVisitResult2.IsDeletedInSDH__c = 'N';
        externalVisitResult2.VISITNUM__c = 2;

        Integration_VisitResult__c externalVisitResult3 = new Integration_VisitResult__c();
        externalVisitResult3.USUBJID__c = '1~2~3';
        externalVisitResult3.VISIT__c = 'Unscheduled';
        externalVisitResult3.VSDTC__c = Date.today();
        externalVisitResult3.TESTCD__c = 'BUNCC';
        externalVisitResult3.Vital_or_Lab__c = 'Vital';
        externalVisitResult3.STNRHI__c = 11;
        externalVisitResult3.STUDYID__c = '10';
        externalVisitResult3.IsDeletedInSDH__c = 'N';
        externalVisitResult3.VISITNUM__c = 1.12;

        Integration_VisitResult__c externalVisitResult4 = new Integration_VisitResult__c();
        externalVisitResult4.USUBJID__c = '1~2~3';
        externalVisitResult4.VISIT__c = 'Unscheduled';
        externalVisitResult4.VSDTC__c = Date.today();
        externalVisitResult4.TESTCD__c = 'BUNCC';
        externalVisitResult4.Vital_or_Lab__c = 'Vital';
        externalVisitResult4.STNRHI__c = 11;
        externalVisitResult4.STUDYID__c = '10';
        externalVisitResult4.IsDeletedInSDH__c = 'N';
        externalVisitResult4.VISITNUM__c = 1.14;

        Integration_VisitResult__c externalVisitResult5 = new Integration_VisitResult__c();
        externalVisitResult5.USUBJID__c = '1~2~3';
        externalVisitResult5.VISIT__c = 'Unscheduled';
        externalVisitResult5.VSDTC__c = visitDate5;
        externalVisitResult5.TESTCD__c = 'BUNCC';
        externalVisitResult5.Vital_or_Lab__c = 'Vital';
        externalVisitResult5.STNRHI__c = 11;
        externalVisitResult5.STUDYID__c = '10';
        externalVisitResult5.IsDeletedInSDH__c = 'N';
        externalVisitResult5.VISITNUM__c = 1.7;

        Integration_VisitResult__c externalVisitResult6 = new Integration_VisitResult__c();
        externalVisitResult6.USUBJID__c = '1~2~3';
        externalVisitResult6.VISIT__c = 'Unscheduled';
        externalVisitResult6.VSDTC__c = visitDate5;
        externalVisitResult6.TESTCD__c = 'BUNCC';
        externalVisitResult6.Vital_or_Lab__c = 'Vital';
        externalVisitResult6.STNRHI__c = 11;
        externalVisitResult6.STUDYID__c = '10';
        externalVisitResult6.IsDeletedInSDH__c = 'N';
        externalVisitResult6.VISITNUM__c = 1.73;

        ivrList.add(externalVisitResult1);
        ivrList.add(externalVisitResult2);
        ivrList.add(externalVisitResult3);
        ivrList.add(externalVisitResult4);
        ivrList.add(externalVisitResult5);
        ivrList.add(externalVisitResult6);

        Database.insert(ivrList);
        List<Patient_Visit__c> pvList = [
            SELECT Id, Participant_Enrollment__r.External_Key__c, Name, Completed_Date__c
            FROM Patient_Visit__c
        ];
        List<Visit_Result__c> visitResultList = new List<Visit_Result__c>();
        Visit_Result__c vr1 = new Visit_Result__c(
            Result_Type__c = 'BUN',
            Patient_Visit__c = pvList[0].Id,
            SDH_Key__c = '1~2~3New Visit' + Date.today()
        );

        Visit_Result__c vr2 = new Visit_Result__c(
            Actual_Value__c = 1.0000,
            Result_Type__c = 'New_York_carcinoma',
            Patient_Visit__c = pvList[0].Id,
            SDH_Key__c = '1~2~3New Visit' + Date.today()
        );

        Visit_Result__c vr3 = new Visit_Result__c(
            Actual_Value__c = 1.0000,
            Result_Type__c = 'BUN',
            Patient_Visit__c = pvList[0].Id,
            SDH_Key__c = '1~2~3Unscheduled' + Date.today()
        );

        Visit_Result__c vr5 = new Visit_Result__c(
            Actual_Value__c = 1.0000,
            Result_Type__c = 'BUN',
            Patient_Visit__c = pvList[0].Id,
            SDH_Key__c = '1~2~3Unscheduled' + visitDate5
        );
        Visit_Result__c vr6 = new Visit_Result__c(
            Actual_Value__c = 1.0000,
            Result_Type__c = 'BUN',
            Patient_Visit__c = pvList[0].Id,
            SDH_Key__c = '1~2~3Unscheduled' + visitDate5
        );

        visitResultList.add(vr1);
        visitResultList.add(vr2);
        visitResultList.add(vr3);
        visitResultList.add(vr5);
        visitResultList.add(vr6);
        insert visitResultList;
    }

    @IsTest
    private static void getVisitResultsGroupNames_test() {
        List<Participant_Enrollment__c> peList = [
            SELECT Id, External_Key__c
            FROM Participant_Enrollment__c
            WHERE External_Key__c = '1~2~3'
            LIMIT 1
        ];

        VisitResultsService service = new VisitResultsService();
        // service.getPatientVisitsForReport(peList[0]);
        Test.startTest();
        List<String> testNames = service.getVisitResultsGroupNames('Vitals');
        Test.stopTest();

        System.assert(testNames[0].equals('Vitals'));
    }

    @IsTest
    private static void getVisitResultWrappersForDashboard_test() {
        VisitResultsService service = new VisitResultsService();

        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        testData.ctp.Shareback_Settings_Countries__c = 'US';
        testData.ctp.Participant_Visit_Result_Group__c = 'Hematology';
        update testData.ctp;

        Test.startTest();
        testData.pe.Clinical_Trial_Profile__c = testData.ctp.id;
        update testData.pe;
        testData.participant.Mailing_Country_Code__c = 'US';
        update testData.participant;
        System.runAs(testData.participantUser) {
            List<Visit_Result_Type_Sharing__c> vrslist = new List<Visit_Result_Type_Sharing__c>();
            Visit_Result_Type_Sharing__c vrts = new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'WBC_Count',
                Sharing_Countries__c = 'US',
                Custom_Tooltip__c = 'Test 123 Custom Tool tip'
            );
            vrslist.add(vrts);
            Visit_Result_Type_Sharing__c vrts1 = new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = false,
                Type__c = 'WBC_Count',
                Sharing_Countries__c = 'UK',
                Custom_Tooltip__c = 'Test Custom Tool tip'
            );
            vrslist.add(vrts1);
            insert vrslist;
        }
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
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
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
                Patient_Visit__c = patientVisits.get(3).Id,
                Result_Type__c = 'Calcium'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.8,
                Patient_Visit__c = patientVisits.get(4).Id,
                Result_Type__c = 'Calcium'
            )
        );
        insert visitResults;

        System.runAs(testData.participantUser) {
            ClassFactory.clearStubTypesByClassNamesMap();
            List<VisitResultsService.VisitResultWrapper> wrappers = service.getVisitResultWrappersForDashboard();
            System.assert(wrappers != null);
        }
        Test.stopTest();
    }

    @IsTest
    private static void getVisitResultWrappersForDashboardWithEmptyVisitResult_test() {
        VisitResultsService service = new VisitResultsService();
        List<Visit_Result_TypeM_Dashboard_Config__mdt> configs = new List<Visit_Result_TypeM_Dashboard_Config__mdt>{};

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
            VisitResultMService.class,
            StubBuilder.newInstance(VisitResultMService.class)
                .when('getVisitResultTypeDashboardConfigs')
                .then(configs)
                .build()
        );

        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Test.startTest();
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

        testData.updatePEStatusEnrollmentSuccess();

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
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
            )
        );
        insert patientVisits;

        System.runAs(testData.participantUser) {
            List<VisitResultsService.VisitResultWrapper> wrappers = service.getVisitResultWrappersForDashboard();
            System.assert(wrappers != null);
        }
        Test.stopTest();
    }

    @IsTest
    private static void getVisitResultsContainer_test() {
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
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Test.startTest();
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
        visits.add(new Visit__c(Visit_Plan__c = vp.Id));
        insert visits;

        testData.updatePEStatusEnrollmentSuccess();

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
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
            )
        );
        patientVisits.add(
            new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Pending',
                Visit__c = visits.get(5).Id,
                Visit_Number__c = 5
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
                Patient_Visit__c = patientVisits.get(3).Id,
                Result_Type__c = 'Calcium'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.8,
                Patient_Visit__c = patientVisits.get(4).Id,
                Result_Type__c = 'Calcium'
            )
        );

        insert visitResults;

        System.runAs(testData.participantUser) {
            VisitResultsService service = new VisitResultsService();
            //service.getPatientVisitsForReport(peList[0]);

            VisitResultMService visitResultMService = new VisitResultMService();
            String resultType = visitResults.get(0).Result_Type__c;
            String visitResultGroup = visitResultMService.getVisitResultGroupByTypeName(resultType);
            List<String> sharings = new List<String>();
            sharings.add(resultType);
            Map<String, List<String>> visitResultSharings = new Map<String, List<String>>();
            visitResultSharings.put(visitResultGroup, sharings);
            VisitResultsService.VisitResultsContainer container = service.getVisitResultsContainer(
                visitResultGroup,
                visitResultSharings,
                ParticipantContext.getCurrentPE().Clinical_Trial_Profile__c,
                ParticipantContext.getCurrentPE().Participant__r.Mailing_Country_Code__c
            );
            System.assertEquals(1, container.wrappers.size());
        }
        update visits;
        delete visits;
        Test.stopTest();
    }
}
