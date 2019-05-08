/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_BaselineSurveyRemote {
    
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            BaselineSurveyRemote.getBaselineSurveyURL(CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest(); 

    }
}