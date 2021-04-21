@IsTest
public class Test_Batch_DataCleanup_EligibilityFailed {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
         Test.startTest();
        TestData td = new TestData();
        td.pe.Participant_Status__c = 'Eligibility Failed';
        update td.pe;

        Database.executeBatch(new Batch_DataCleanup_EligibilityFailed());
        Test.stopTest();


    }
}