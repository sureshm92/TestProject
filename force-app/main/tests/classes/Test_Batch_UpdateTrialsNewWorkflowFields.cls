/**
 * Created by Nargiz Mamedova on 7/9/2020.
 */

@IsTest
private class Test_Batch_UpdateTrialsNewWorkflowFields {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData td = new TestData();
        td.ss.Study_Site_Type__c = 'Traditional';
        update td.ss;
        Test.startTest();
        Database.executeBatch(new Batch_UpdateTrialsNewWorkflowFields());
        Test.stopTest();
        List<Clinical_Trial_Profile__c> clinicalTrialProfiles = [
                SELECT Id, Initial_Visit_Required__c
                FROM Clinical_Trial_Profile__c
                WHERE Id =: td.ctp.Id
        ];
        System.assertEquals(true, clinicalTrialProfiles[0].Initial_Visit_Required__c);
    }
}