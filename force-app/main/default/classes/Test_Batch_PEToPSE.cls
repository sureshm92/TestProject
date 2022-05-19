@IsTest
public class Test_Batch_PEToPSE {
    @TestSetup
    static void testBehavior() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    static void Test() {
        TestData testdata = new TestData();
        List<Id> peIds = new List<Id>();
        Test.startTest();
        DataBase.executeBatch(new Batch_PEToPSE(peIds));
        Test.stopTest();
    }
}
