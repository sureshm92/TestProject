/**
 * Created by Nargiz Mamedova on 6/4/2020.
 */

@IsTest
private class Test_Batch_UpdateRecords {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData td = new TestData();
        td.ctp.Study_Code_Name__c = null;
        update td.ctp;

        Test.startTest();
        Batch_UpdateRecords.run();
        Test.stopTest();

        List<Clinical_Trial_Profile__c> resCTPs = [
                SELECT Id, Study_Code_Name__c
                FROM Clinical_Trial_Profile__c
                WHERE Id =: td.ctp.Id
        ];
        System.assertEquals(
                td.ctp.Study_Title__c.mid(0, Clinical_Trial_Profile__c.Study_Code_Name__c.getDescribe().getLength()),
                resCTPs[0].Study_Code_Name__c
        );
    }
}