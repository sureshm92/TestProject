@IsTest
public class Test_Batch_UpdatePESHStatuses {
    @TestSetup
    static void testBehavior() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    static void Test() {
        TestData testdata = new TestData();
        Test.startTest();
        string peId;
        peId = testdata.pe.Id;
        Set<String> peIds = new Set<String>();
        DataBase.executeBatch(new Batch_UpdatePEStatuses());
        DataBase.executeBatch(new Batch_UpdatePEStatuses(peId));
        DataBase.executeBatch(new Batch_UpdatePEStatuses(peIds));
        Test.stopTest();
    }
}
