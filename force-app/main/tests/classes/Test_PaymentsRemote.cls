/**
 * Created by Nargiz Mamedova on 3/3/2020.
 */

@IsTest
public class Test_PaymentsRemote {

    @IsTest(SeeAllData = true)
    public static void testBehavior() {

        User user = [
                SELECT Id
                FROM User
                WHERE ContactId != NULL
                LIMIT 1
        ];

        PaymentsRemote.InitData initData;

        Test.startTest();
        System.runAs(user) {
            Test.setMock(HttpCalloutMock.class, new GetCardDetailsHttpCalloutMock());
            initData = PaymentsRemote.getPaymentData();
        }
        Test.stopTest();

        System.assertEquals(2, initData.cards.size());
    }
}