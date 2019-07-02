/**
 * Created by Leonid Bartenev
 *
 * All integration tests for Patient Portal should be here,
 * test data initialised one time in init() method for saving of time
 *
 */

@IsTest
private class Test_BasePPCommunity {
    
    @TestSetup
    public static void init(){
        TestData.loadTestData();
    }
    
    @IsTest
    static void pseCreationTest() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.createPSE();
        Test.stopTest();
        System.assert(testDataInstance.pe.Screening_ID__c == testDataInstance.pse.Screening_ID__c, 'ScreeningId not copied from PE to PSE');
    }
    
}