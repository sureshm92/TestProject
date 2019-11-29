/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_StudyActionParticipant {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser){
            new StudyActionsParticipant();
        }
        Test.stopTest();
    }
}