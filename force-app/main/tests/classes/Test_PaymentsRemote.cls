/**
 * Created by Nargiz Mamedova on 3/3/2020.
 */

@IsTest
public class Test_PaymentsRemote {

    @IsTest
    public static void testBehavior() {
        TestData.loadTestData();
        TestData td = new TestData();

        PaymentsRemote.InitData initData = new PaymentsRemote.InitData();
        Test.startTest();
        System.runAs(td.participantUser) {
            Test.setMock(HttpCalloutMock.class, new GetCardDetailsHttpCalloutMock());
            initData = PaymentsRemote.getPaymentData();
        }
        Test.stopTest();
//        System.assertEquals(2, initData.cards.size());
    }
}