/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_AlertRemote {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.createPSE();
        System.runAs(testDataInstance.participantUser){
            List<Alert> alerts = (List<Alert>)JSON.deserialize(AlertsRemote.getAlerts(CommunityService.USER_MODE_PARTICIPANT), List<Alert>.class);
            AlertsRemote.setAlertViewed(alerts[0].id);
            
        }
        Test.stopTest();
    }
    
}