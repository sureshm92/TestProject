/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_PSEStatusHistoryRemote {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            PSEStatusHistoryRemote.getPSEStatusHistory(testData.pse.Id);
        }
        Test.stopTest();
    }
}