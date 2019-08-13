/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_PSEStatusHistoryRemote {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.createPSE();
        System.runAs(testDataInstance.participantUser){
            PSEStatusHistoryRemote.getParticipationStatusHistory(testDataInstance.pe.Id);
        }
        Test.stopTest();
    }
}