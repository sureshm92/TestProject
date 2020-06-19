/**
 * Created by dmytro.fedchyshyn on 01.08.2019.
 */
@IsTest
private class Test_VisitReportService {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void integrationTest() {
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
        
        List<Patient_Visit__c> patientVisits = new List<Patient_Visit__c>();
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
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
                Completed_Date__c = Date.today(),
                Visit__c = visits.get(2).Id,
                Visit_Number__c = 3
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
                Visit__c = visits.get(3).Id,
                Visit_Number__c = 3.1
        ));
        patientVisits.add(new Patient_Visit__c(
                Participant_Enrollment__c = testData.pe.Id,
                Status__c = 'Completed',
                Completed_Date__c = Date.today(),
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

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        update testData.pe;
      
        System.runAs(testData.participantUser){
            VisitReportContainerRemote.getReportDataWrappers(testData.pe.Id);
            try{
                VisitReportContainerRemote.getLogoFromStatic('GSK');
            }
            catch(Exception e){
                System.debug('Exception Handled');
            }
        }
        
        Test.stopTest();
    }
    
}