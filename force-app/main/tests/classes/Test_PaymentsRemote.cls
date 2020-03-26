/**
 * Created by Nargiz Mamedova on 3/3/2020.
 */

@IsTest
public class Test_PaymentsRemote {
    public class ParticipantServiceMock implements System.StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getState') {
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @IsTest
    public static void testBehavior() {
        PaymentsRemote.InitData initData;

        Test.startTest();
        ParticipantService.setMock(new ParticipantServiceMock());
        Test.setMock(HttpCalloutMock.class, new GetCardDetailsHttpCalloutMock());
        initData = PaymentsRemote.getPaymentData();
        Test.stopTest();

        System.assertEquals(2, initData.cards.size());
    }
}