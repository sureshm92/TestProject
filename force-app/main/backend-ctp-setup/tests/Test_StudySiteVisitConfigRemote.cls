/**
 * Created by Yulia Yakushenkova on 10/17/2019.
 */

@IsTest
private class Test_StudySiteVisitConfigRemote {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();

        Visit_Plan__c visitPlan = new Visit_Plan__c(Name = 'Test_StudySiteVisitConfigRemote VP');
        insert visitPlan;

        StudySiteVisitConfigRemote.InitData initData = StudySiteVisitConfigRemote.getInitData(
            testData.ctp.Id
        );
        String ssItemsJS = JSON.serialize(initData.searchResponse.studySiteItems);
        String filterJS = JSON.serialize(initData.filter);
        String paginationJS = JSON.serialize(initData.searchResponse.pagination);

        StudySiteVisitConfigRemote.getItems(
            ssItemsJS,
            filterJS,
            paginationJS,
            null,
            testData.ctp.Id
        );
        StudySiteVisitConfigRemote.setVisitPlanForAll(
            visitPlan.Id,
            true,
            filterJS,
            paginationJS,
            ssItemsJS,
            null,
            testData.ctp.Id,
            null,
            false
        );
        StudySiteVisitConfigRemote.deleteVisitPlan(visitPlan.Id, filterJS, paginationJS);
        StudySiteVisitConfigRemote.getLatestBatchStatusForStudy(testData.ctp.Id, filterJS);
        Map<Id, Study_Site__c> studySiteMap = new Map<Id, Study_Site__c>(
            [SELECT Id FROM Study_Site__c]
        );
        StudySiteVisitConfigRemote.getLatestBatchStatusForStudySites(
            new List<Id>(studySiteMap.keyset())
        );
        StudySiteVisitConfigRemote.totalPEs(testData.ctp.Id, filterJS);
        Test.stopTest();
    }
}
