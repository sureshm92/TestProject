@isTest
public class Test_Batch_CreateECOASubjectEvents {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @isTest
    private static void Batch_CreateECOASubjectEvents() {
        TestData testData = new TestData();
        Test.startTest();
        Set<Id> peId = new Set<Id>();
        DataBase.executeBatch(new Batch_CreateECOASubjectEvents(peId));
        Test.stopTest();
    }
}
