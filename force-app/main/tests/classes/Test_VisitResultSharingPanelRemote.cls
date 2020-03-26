/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_VisitResultSharingPanelRemote {

    @IsTest
    static void testAll() {
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.startTest();
        TestData testData = new TestData();
        VisitResultSharingPanelRemote.InitData initData = VisitResultSharingPanelRemote.getInitData(testData.ctp.Id);
        VisitResultSharingPanelRemote.saveSharingRules(JSON.serialize(initData.options), JSON.serialize(initData.groups), testData.ctp.Id);
        Test.stopTest();
    }
}