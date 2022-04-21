@isTest
public class Test_TrialService {
    @isTest
    private static void getResourceList() {
        TestData.loadTestData();
        Test.startTest();
        List<Resource__c> resources = [SELECT Id, Title__c FROM Resource__c];

        TrialService.getInstance();

        Test.stopTest();
    }
}
