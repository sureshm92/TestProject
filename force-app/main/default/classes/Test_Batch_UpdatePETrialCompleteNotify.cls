/**
 * Created by Yulia Yakushenkova on 1/27/2020.
 */

@IsTest
private class Test_Batch_UpdatePETrialCompleteNotify {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData testData = new TestData();
        testData.createPatientDelegate();

        List<Clinical_Trial_Profile__c> ctps = [SELECT Id FROM Clinical_Trial_Profile__c];
        List<Id> ctpIds = new List<Id>();
        for(Clinical_Trial_Profile__c ctp : ctps) ctpIds.add(ctp.Id);

        Test.startTest();
        Database.executeBatch(new Batch_UpdatePETrialCompleteAndSendNotify(ctpIds));
        Test.stopTest();
    }
}