/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_MotivationalMessagesRemote {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            MotivationalMessagesRemote.getMotivationalMessage(CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }
}