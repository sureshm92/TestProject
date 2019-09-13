/**
 * Created by Slav on 20.08.2019.
 */

@IsTest(SeeAllData=false)
public class Test_AlertsRemote {
    
    @IsTest
    public static void testRun () {
        try {
            AlertsRemote.getAlerts('alert');
        } catch (Exception e) {
            // expected Exception
        }
        
        TestData.loadTestData();
        Test.startTest();
        
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser){
            List<Alert> alerts = (List<Alert>)JSON.deserialize(AlertsRemote.getAlerts(CommunityService.USER_MODE_PARTICIPANT), List<Alert>.class);
            AlertsRemote.setAlertViewed(alerts[0].id);
            
            try {
                AlertsRemote.setAlertViewed(null);
            } catch (Exception e) {
                // expected Exception
            }
        }
        
        Test.stopTest();
    }

}