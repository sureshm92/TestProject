/**
 * Created by Olga Skrynnikova on 1/16/2020.
 */

@IsTest
private class Test_BatchDataBecomesAvailable {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testdataBecomesAvailiable() {
        TestData testData = new TestData();

        Test.startTest();
        testData.ss.Visit_Results_Sharing__c = true;
        update testData.ss;

        testData.ctp.Visit_Data_Shareback__c = true;
        testData.ctp.Shareback_Availability_Timing__c = 0.0;
        update testData.ctp;

        testData.pe.Participant_Contact__r.Visit_Results_Opt_In__c = true;  // TODO Depricated
        testData.pe.Participant_Contact__r.Visit_Results_OptIn__c = 'Vitals;Labs;Biomarkers';
        testData.pe.Participant_Contact__r.Participant_Opt_In_Status_Emails__c = true;
        update testData.pe.Participant_Contact__r;

        List<Visit_Result_Type_Sharing__c> visitResultTypeSharings = new List<Visit_Result_Type_Sharing__c>();
        visitResultTypeSharings.add(new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'Calcium',
                Sharing_Countries__c = 'US'
        ));
        visitResultTypeSharings.add(new Visit_Result_Type_Sharing__c(
                Clinical_Trial_Profile__c = testData.ctp.Id,
                Include_Countries__c = true,
                Type__c = 'BUN',
                Sharing_Countries__c = 'US'
        ));
        insert visitResultTypeSharings;

        Visit_Plan__c vp = new Visit_Plan__c(Name = 'Test Plan');
        insert vp;

        Visit__c visit = new Visit__c(Visit_Plan__c = vp.Id);
        insert visit;

        Patient_Visit__c patientVisit = new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Visit__c = visit.Id,
                Visit_Number__c = 1,
                Completed_Date__c = Date.newInstance(2019, 12, 17)
        );
        insert patientVisit;

        List<Visit_Result__c> visitResults = new List<Visit_Result__c>();
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.01,
                Patient_Visit__c = patientVisit.Id,
                Result_Type__c = 'Calcium'
        ));
        visitResults.add(new Visit_Result__c(
                Actual_Value__c = 0.5,
                Patient_Visit__c = patientVisit.Id,
                Result_Type__c = 'BUN'
        ));
        insert visitResults;

        Database.executeBatch(new Batch_DataBecomesAvailable());
        Test.stopTest();
    }
}