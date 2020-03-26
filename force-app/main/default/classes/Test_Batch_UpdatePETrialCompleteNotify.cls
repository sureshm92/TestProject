/**
 * Created by Yulia Yakushenkova on 1/27/2020.
 */

@IsTest
private class Test_Batch_UpdatePETrialCompleteNotify {

    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testBehavior() {
        TestData testData = new TestData();
        testData.createPatientDelegate();

        Test.startTest();
        List<Clinical_Trial_Profile__c> ctps = [SELECT Id FROM Clinical_Trial_Profile__c];
        for(Clinical_Trial_Profile__c ctp : ctps) {
            ctp.Status__c = 'Completed';
        }
        update ctps;

        //Database.executeBatch(new Batch_UpdatePETrialCompleteAndSendNotify(ctpIds));
        Test.stopTest();
        Participant_Enrollment__c pe = [SELECT Id, Participant_Status__c FROM Participant_Enrollment__c WHERE Participant__r.Last_Name__c = 'ParticipantTD'];
        System.assertEquals('Trial Complete', pe.Participant_Status__c);
    }
}