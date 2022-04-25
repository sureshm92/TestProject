@isTest
public class Test_TrialService {
    @isTest
    private static void testTrial() {
        Test.startTest();
        List<Resource__c> resources = [SELECT Id, Title__c FROM Resource__c];
        TrialService ts = new TrialService();
        ts.getAvailableTrialsImpl('CommunityService.USER_MODE_PI');
        ts.getOwnTrialsImpl('CommunityService.USER_MODE_PI');
        ts.getAvailableTrialIdsImpl('CommunityService.USER_MODE_PI');
        TrialService.getOwnTrials('CommunityService.USER_MODE_PI');
        TrialService.getAvailableTrialIds('CommunityService.USER_MODE_PI');
        TrialService.getInstance();
        Test.stopTest();
    }
}
