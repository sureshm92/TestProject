/**
 * Created by Nargiz Mamedova on 3/23/2020.
 */

@IsTest
private class Test_EmptyPagePanelRemote {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        TestData testData = new TestData();
        Test.startTest();
        EmptyPagePanelRemote.getPermission(testData.ctp.Id, 'Trial_Surveys');
        Test.stopTest();
    }
}