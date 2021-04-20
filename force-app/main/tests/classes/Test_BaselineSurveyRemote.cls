/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_BaselineSurveyRemote {
    //Set Mock Object---------------------------------------------------------------------------------------------------
    public class SurveyServiceMock implements StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getSurveyLinkForCTP') {
                return new SurveyService.SurveyWrapper('some', 'url', 'SCN');
            }
            if (stubbedMethodName == 'getSurveyInvitationId') {
                return TestDataFactory.getFakeId(SurveyInvitation.getSObjectType());
            }
            if (stubbedMethodName == 'isInvitationExpired') {
                return false;
            }
            return null;
        }
    }

    @IsTest
    static void testBehavior() {
        SurveyService.setMock(new SurveyServiceMock());

        TestData.loadTestData();
        TestData testDataInstance = new TestData();
        Id invitationId;
        Boolean checkId;

        Test.startTest();
        System.runAs(testDataInstance.participantUser) {
            invitationId = SurveyService.getInstance().getSurveyInvitationId('000', '111');
            BaselineSurveyRemote.getBaselineSurveyURL(
                CommunityService.USER_MODE_PI,
                invitationId
            );
            checkId = invitationId != null ? true : false;
        }
        Test.stopTest();

        System.assertEquals(true, checkId);
    }
}
