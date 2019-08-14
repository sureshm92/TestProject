/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_MotivationalMessagesRemote {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.updatePEStatusEnrollmentSuccess();
        System.runAs(testDataInstance.participantUser){
            MotivationalMessagesRemote.getMotivationalMessage(CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }
}