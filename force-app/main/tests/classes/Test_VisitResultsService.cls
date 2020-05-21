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
    }

    @IsTest
    private static void getVisitResultsGroupNames_test() {

        VisitResultsService service = new VisitResultsService();

        Test.startTest();
        List<String> testNames = service.getVisitResultsGroupNames('Vitals');
        Test.stopTest();

        System.assert( testNames[0].equals('Vitals'));
    }

    @IsTest
    private static void getVisitResultWrappersForDashboard_test() {
        VisitResultsService service = new VisitResultsService();

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
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
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
        ClassFactory.putStubTypeByClassName(VisitResultMService.class, StubBuilder.newInstance(VisitResultMService.class)
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
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
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

        List<Visit_Result_TypeM__mdt> types = new List<Visit_Result_TypeM__mdt>{
                new Visit_Result_TypeM__mdt()
        };

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
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(0).Id,
                Visit_Number__c = 1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
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
            VisitResultsService service = new VisitResultsService();
            VisitResultMService visitResultMService = new VisitResultMService();
            String resultType = visitResults.get(0).Result_Type__c;
            String visitResultGroup =
                    visitResultMService.getVisitResultGroupByTypeName(resultType);
            List<String> sharings = new List<String>();
            sharings.add(resultType);
            Map<String, List<String>> visitResultSharings = new  Map<String, List<String>>();
            visitResultSharings.put(visitResultGroup, sharings);
            VisitResultsService.VisitResultsContainer container =
                    service.getVisitResultsContainer(visitResultGroup,visitResultSharings);
            System.assertEquals(1, container.wrappers.size());
        }

        Test.stopTest();
    }

}