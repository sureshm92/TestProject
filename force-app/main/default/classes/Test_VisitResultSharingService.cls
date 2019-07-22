/**
 * Created by Igor Malyuta on 28.06.2019.
 */
@IsTest
private class Test_VisitResultSharingService {

    @IsTest
    static void processResultsTest() {
        TestData.loadTestData();
        TestData testData = new TestData();

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

        Visit__c visit = new Visit__c(
                Order__c = 3,
                Visit_Plan__c = vp.Id
        );
        insert visit;

        testData.createPSE();
        Patient_Visit__c pv = new Patient_Visit__c(
                Participant_Study_Enrollment__c = testData.pse.Id,
                Visit__c = visit.Id
        );
        insert pv;

        Visit_Result__c vr = new Visit_Result__c(
                Patient_Visit__c = pv.Id,
                Result_Type__c = 'Calcium'
        );
        insert vr;

        List<Visit_Result__c> visitResults;
        System.runAs(testData.participantUser){
            visitResults = VisitResultSharingService.processResults();
        }
        Test.stopTest();

        System.assertEquals(1, visitResults.size());
    }

    @IsTest
    static void testAll() {
        TestData.loadTestData();

        Test.startTest();
        TestData testData = new TestData();
        testData.createPSE();

        System.runAs(testData.participantUser) {
            VisitResultSharingService.isVisitResultAvailable();
            VisitResultSharingService.getCTP(testData.ctp.Id);
            VisitResultSharingService.disableShareback(testData.ctp);
            VisitResultSharingService.getTypeVRSharingMap(testData.ctp);
            VisitResultSharingService.updateStudySitesSharing(testData.ctp.Id, new List<String>{testData.ss.Id}, true);
        }

        Test.stopTest();
    }
}