/**
 * Created by dmytro.fedchyshyn on 05.08.2019.
 */

@IsTest
private class Test_VisitResultsService {

    @IsTest
    private static void getVisitResultsGroupNames_test() {

        VisitResultsService service = new VisitResultsService();

        List<String> groupNames = new List<String>{
                'first', 'second'
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultMService.class, StubFactory.newInstance(VisitResultMService.class)
                .when('getVisitResultGroupNames')
                .then(groupNames)
                .getInstance()
        );

        Test.startTest();
        List<String> testNames = service.getVisitResultsGroupNames(null);
        Test.stopTest();

        System.assertEquals(2, testNames.size());
    }

    @IsTest
    private static void getPatientVisitsForReportWithPse_test() {
        VisitResultsService service = new VisitResultsService();
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
        ctp.Visit_Plan__c = TestDataFactory.getFakeId(Visit_Plan__c.getSObjectType());
        pState.ctp = ctp;
        Participant_Study_Enrollment__c pse = new Participant_Study_Enrollment__c();
        pState.pse = pse;
        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>{
                new Patient_Visit__c(),
                new Patient_Visit__c()
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubFactory.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .getInstance()
        );
        ClassFactory.putStubTypeByClassName(DatabaseProxy.class, StubFactory.newInstance(DatabaseProxy.class)
                .when('query')
                .then(patientVisits)
                .getInstance()
        );

        Test.startTest();
        List<Patient_Visit__c> testPatientVisits = service.getPatientVisitsForReport();
        Test.stopTest();

        System.assertEquals(2, testPatientVisits.size());
    }

    @IsTest
    private static void getPatientVisitsForReportWithOutPse_test() {
        VisitResultsService service = new VisitResultsService();
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubFactory.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .getInstance()
        );

        Test.startTest();
        List<Patient_Visit__c> visits = service.getPatientVisitsForReport();
        Test.stopTest();
        System.assert(visits == null);
    }

    @IsTest
    private static void getVisitResultWrappersForDashboard_test() {
        VisitResultsService service = new VisitResultsService();

        TestData.loadTestData();
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

        testData.createPSE();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
        ));
        insert patientVisits;

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium'
        ));
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(3).Id,
                Result_Type__c = 'Calcium'
        ));
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.8,
                Patient_Visit__c = patientVisits.get(4).Id,
                Result_Type__c = 'Calcium'
        ));
        insert visitResults;

        System.runAs(testData.participantUser) {
            ClassFactory.clearStubTypesByClassNamesMap();
            ClassFactory.putStubTypeByClassName(VisitResultMService.class, StubFactory.newInstance(VisitResultMService.class)
                    .when('getVisitResultTypeDashboardConfigs')
                    .then(configs)
                    .getInstance()
            );
            List<VisitResultsService.VisitResultWrapper> wrappers = service.getVisitResultWrappersForDashboard();
            System.assert(wrappers != null);
        }
        Test.stopTest();
    }

    @IsTest
    private static void getVisitResultWrappersForDashboardWithEmptyVisitResult_test() {
        VisitResultsService service = new VisitResultsService();
        List<Visit_Result_TypeM_Dashboard_Config__mdt> configs = new List<Visit_Result_TypeM_Dashboard_Config__mdt>{
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultMService.class, StubFactory.newInstance(VisitResultMService.class)
                .when('getVisitResultTypeDashboardConfigs')
                .then(configs)
                .getInstance()
        );

        TestData.loadTestData();
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

        testData.createPSE();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
        ));
        insert patientVisits;

        System.runAs(testData.participantUser) {
            List<VisitResultsService.VisitResultWrapper> wrappers = service.getVisitResultWrappersForDashboard();
            System.assert(wrappers != null);
        }
        Test.stopTest();
    }

    @IsTest
    private static void getVisitResultsContainer_test() {
        VisitResultsService service = new VisitResultsService();
        List<Visit_Result_TypeM__mdt> types = new List<Visit_Result_TypeM__mdt>{
                new Visit_Result_TypeM__mdt()
        };

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(VisitResultMService.class, StubFactory.newInstance(VisitResultMService.class)
                .when('getVisitResultTypes')
                .then(types)
                .getInstance()
        );

        TestData.loadTestData();
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

        testData.createPSE();

        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4
        ));
        insert patientVisits;

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisits.get(0).Id,
                Result_Type__c = 'Calcium'
        ));
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(3).Id,
                Result_Type__c = 'Calcium'
        ));
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.8,
                Patient_Visit__c = patientVisits.get(4).Id,
                Result_Type__c = 'Calcium'
        ));
        insert visitResults;

        System.runAs(testData.participantUser) {
            VisitResultsService.VisitResultsContainer container = service.getVisitResultsContainer(null);
            System.assert(container != null);
        }

        Test.stopTest();
    }

    @IsTest
    private static void checkOnAccess_test() {
        VisitResultsService service = new VisitResultsService();
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;

        Test.startTest();
        testData.createPSE();

        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        pState.pse = [
                SELECT Id,
                        Participant_Contact__c,
                        Screening_ID__c,
                        CreatedDate,
                        Study_Site__r.Name
                FROM Participant_Study_Enrollment__c
                WHERE Participant__c = :testData.participant.Id
        ];
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubFactory.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .getInstance()
        );

        System.runAs(testData.participantUser) {
            Boolean access = service.checkOnAccess(pState);

            System.assertEquals(true, access);
        }

        Test.stopTest();
    }
}