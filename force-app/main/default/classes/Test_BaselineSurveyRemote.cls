/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_BaselineSurveyRemote {

    //Set Mock Object---------------------------------------------------------------------------------------------------
    public class SurveyServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getSurveyLink') return 'https://surveygismo.com';
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
            BaselineSurveyRemote.getBaselineSurveyURL(CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest(); 

    }
}