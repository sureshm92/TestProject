/**
 * Created by Yulia Yakushenkova on 10/17/2019.
 */

@IsTest
private class Test_ApprovedLangRemote {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        ApprovedLangRemote.InitData initData = ApprovedLangRemote.getInitData(testData.ctp.Id);
        String ssItemsJS = JSON.serialize(initData.searchResponse.studySiteItems);
        String filterJS = JSON.serialize(initData.filter);
        String paginationJS = JSON.serialize(initData.searchResponse.pagination);

        ApprovedLangRemote.getItems(ssItemsJS, filterJS, paginationJS);
        ApprovedLangRemote.setLanguageForAll(filterJS, paginationJS, 'ru', true);
        ApprovedLangRemote.getCtpStudySites(initData.filter);
        Test.stopTest();
    }
}