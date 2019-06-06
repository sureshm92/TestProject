/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_BaselineSurveyRemote {

    //Set Mock Object---------------------------------------------------------------------------------------------------
    public class SurveyServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getSurveyLinkForCTP') {
                return new SurveyService.SurveyWrapper('some', 'url', 'SCN');
            } else if(stubbedMethodName == 'getSurveyInvitationId') {
                return TestDataFactory.getFakeId(SurveyInvitation.getSObjectType());
            }
            return null;
        }
    }

    @IsTest
    static void testBehavior() {
        SurveyService.setMock(new SurveyServiceMock());

        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            BaselineSurveyRemote.getBaselineSurveyURL(CommunityService.USER_MODE_PARTICIPANT,
                    SurveyService.getInstance().getSurveyInvitationId('000', '111'));
        }
        Test.stopTest();

    }
}