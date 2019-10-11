/**
 * Created by dmytro.fedchyshyn on 01.08.2019.
 */
@IsTest
private class Test_VisitReportService {

    private static VisitReportService service = new VisitReportService();

    @IsTest
    static void getFillReportData_test() {
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        update testData.ctp;
        List<Visit_Result_GroupM__mdt> groupMS = [
                SELECT Id, DeveloperName, Display_Order__c, Visit_Results_Mode__c, (
                        SELECT Id, DeveloperName, Display_Order__c, Visit_Result_Group__c, Description_Label_Api_Name__c
                        FROM Visit_Result_Types__r
                )
                FROM Visit_Result_GroupM__mdt
        ];

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
                Visit_Number__c = 1,
                Completed_Date__c = Date.newInstance(2019, 12, 17)
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Missed',
                Visit__c = visits.get(1).Id,
                Visit_Number__c = 2,
                Completed_Date__c = Date.newInstance(2019, 12, 17)
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3,
                Completed_Date__c = Date.newInstance(2019, 12, 17)
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1,
                Completed_Date__c = Date.newInstance(2019, 12, 17)
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visits.get(4).Id,
                Visit_Number__c = 4,
                Completed_Date__c = Date.newInstance(2019, 12, 17)
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

        List<Patient_Visit__c> patientsVisits = [
                SELECT
                        Id,
                        Completed_Date__c,
                        Participant_Enrollment__c,
                        Visit_Number__c, (
                        SELECT
                                Id,
                                Actual_Value__c,
                                Max_Value__c,
                                Measurement__c,
                                Min_Value__c,
                                Patient_Visit__r.Completed_Date__c,
                                Result_Type__c
                        FROM Visit_Results__r
                )
                FROM Patient_Visit__c
                WHERE Participant_Enrollment__c = :testData.pe.Id
                AND Status__c = 'Completed'
                ORDER BY Completed_Date__c
        ];

        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        pState.pe = [
                SELECT Id,
                        Participant_Contact__c,
                        Screening_ID__c,
                        CreatedDate,
                        Study_Site__r.Name,
                        Enrolled_Date__c
                FROM Participant_Enrollment__c
                WHERE Participant__c = :testData.participant.Id
        ];
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubBuilder.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .build()
        );
        System.runAs(testData.participantUser) {
            Map<String, VisitReportContainerRemote.ReportDataTableWrapper> dataTableWrapperMap = service.getDataTableWrappersByGroupName(patientsVisits, groupMS);
            VisitReportContainerRemote.ReportDataWrapper wrapper = service.getFillReportData(dataTableWrapperMap, groupMS);

            System.assertEquals(1, dataTableWrapperMap.size());
            System.assertEquals(1, wrapper.dataTables.size());
        }
        Test.stopTest();
    }

    @IsTest
    static void getReportDataWrapperFirstIf_test() {
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubBuilder.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .build()
        );

        Test.startTest();
        List<VisitReportContainerRemote.ReportDataWrapper> wrappers = service.getReportDataWrapper();
        Test.stopTest();

        System.assert(wrappers != null);
    }

    @IsTest
    static void getReportDataWrapperSecondIf_test() {
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();
        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubBuilder.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .build()
        );

        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('checkOnAccess')
                .then(false)
                .when('getPatientVisitsForReport')
                .then(patientVisits)
                .build()
        );

        Test.startTest();
        List<VisitReportContainerRemote.ReportDataWrapper> wrappers = service.getReportDataWrapper();
        Test.stopTest();

        System.assert(wrappers != null);
    }

    @IsTest
    static void getReportDataWrapperThirdIf_test() {
        ParticipantService.ParticipantState pState = new ParticipantService.ParticipantState();

        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(ParticipantService.class, StubBuilder.newInstance(ParticipantService.class)
                .when('getState')
                .then(pState)
                .build()
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

        ClassFactory.putStubTypeByClassName(VisitResultsService.class, StubBuilder.newInstance(VisitResultsService.class)
                .when('checkOnAccess')
                .then(false)
                .when('getPatientVisitsForReport')
                .then(patientVisits)
                .build()
        );
        List<VisitReportContainerRemote.ReportDataWrapper> wrappers = service.getReportDataWrapper();
        Test.stopTest();

        System.assert(wrappers != null);
    }
    
}
