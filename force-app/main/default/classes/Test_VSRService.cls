@IsTest
public with sharing class Test_VSRService {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();

        Test.stopTest();
        VisitResultsService service = new VisitResultsService();

        TestData testData = new TestData();
        testData.ctp.Shareback_Availability_Timing__c = 1;
        testData.ctp.Shareback_Settings_Countries__c = 'US';
        testData.ctp.Participant_Visit_Result_Group__c = 'Hematology';
        update testData.ctp;

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
                Result_Type__c = 'WBC_Count'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisits.get(3).Id,
                Result_Type__c = 'WBC_Count'
            )
        );
        visitResults.add(
            new Visit_Result__c(
                Actual_Value__c = 0.8,
                Patient_Visit__c = patientVisits.get(4).Id,
                Result_Type__c = 'WBC_Count'
            )
        );
        insert visitResults;
    }

    @IsTest
    static void getInitData_test() {
        Map<String, String> vrMap = new Map<String, String>();
        vrMap.put('meter', 'meter');
        TestData testData = new TestData();
        VisitResultsService service = new VisitResultsService();
        service.getPatientVisitsForReport(testData.pe);
        Visit_Result__c vrObj = [
            SELECT
                Id,
                Name,
                Actual_Value__c,
                Min_Value__c,
                Max_Value__c,
                RecordType.DeveloperName,
                Measurement__c,
                Patient_Visit__r.Completed_Date__c,
                Patient_Visit__r.Portal_Name__c
            FROM Visit_Result__c
            LIMIT 1
        ];
        vrObj.Measurement__c = 'meter';
        vrObj.Patient_Visit__r.Completed_Date__c = Date.today();
        VisitResultsService.VisitResultWrapper vrWrapper = new VisitResultsService.VisitResultWrapper(
            vrObj,
            'name',
            vrMap
        );
        vrObj.Patient_Visit__r.Completed_Date__c = null;
        VisitResultsService.VisitResultWrapper vrWrapper2 = new VisitResultsService.VisitResultWrapper(
            vrObj,
            'name',
            vrMap
        );
        vrObj.Patient_Visit__r.Completed_Date__c = null;
        vrObj.Measurement__c = 'MEQ/L';
        VisitResultsService.VisitResultWrapper vrWrapper3 = new VisitResultsService.VisitResultWrapper(
            vrObj,
            'name',
            'desc',
            vrMap
        );
        VisitResultsService.VisitResultWrapper vrWrapper4 = new VisitResultsService.VisitResultWrapper(
            vrObj,
            'name'
        );
    }

    @IsTest
    static void getInitData_test2() {
        Test.startTest();
        TestData testData = new TestData();
        Visit_Result__c vrObj = [
            SELECT
                Id,
                Name,
                Actual_Value__c,
                RecordType.DeveloperName,
                Measurement__c,
                Patient_Visit__r.Completed_Date__c,
                Patient_Visit__r.Portal_Name__c
            FROM Visit_Result__c
            LIMIT 1
        ];
        ClassFactory.clearStubTypesByClassNamesMap();

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

        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;
        Test.stopTest();

        List<Visit_Result__c> vrList = new List<Visit_Result__c>();

        //VisitResultSharingService.processResults
        System.runAs(testData.participantUser) {
            // try{
            VisitResultsService obj = new VisitResultsService();
            obj.getVisitResultWrappersForDashboard();
            /** }catch(Exception e)
        {
            System.debug(e.getMessage());
            //Contact c = null;
            //System.debug(c.Id);
        }  **/
        }

    }
}
