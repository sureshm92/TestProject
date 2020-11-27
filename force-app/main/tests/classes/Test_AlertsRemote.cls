/**
 * Created by Slav on 20.08.2019.
 */

@IsTest(SeeAllData=false)
public class Test_AlertsRemote {
    @TestSetup
    static void init() {
        try {
            AlertsRemote.getAlerts('alert');
        } catch (Exception e) {
            // expected Exception
        }
        TestData.loadTestData();
    }
    @IsTest
    public static void testRun() {
        List<Alert> alerts = new List<Alert>();
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {
            alerts = (List<Alert>) JSON.deserialize(
                AlertsRemote.getAlerts(CommunityService.USER_MODE_PARTICIPANT),
                List<Alert>.class
            );
            AlertsRemote.setAlertViewed(alerts[0].id);
        }
        Test.stopTest();

        System.assertEquals(1, alerts.size());
    }

    @IsTest
    public static void testException() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        try {
            AlertsRemote.setAlertViewed(null);
        } catch (Exception e) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assertEquals(true, isExceptionThrown);
    }
}
