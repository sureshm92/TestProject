@isTest
public class Test_Batch_CreateEcoaTasks {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    private static void Batch_CreateEcoaTasks() {
        TestData testData = new TestData();
        Test.startTest();
        DataBase.executeBatch(new Batch_CreateEcoaTasks());
        Batch_CreateEcoaTasks bcet = new Batch_CreateEcoaTasks();
        bcet.getBatchDescription();
        bcet.getRecommendedRelaunchInterval();
        bcet.getRecommendedScopeSize();
        Test.stopTest();
    }
}
