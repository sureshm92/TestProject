/**
 * Created by Nargiz Mamedova on 3/23/2020.
 */

@IsTest(isParallel = false)
private class Test_EmptyPagePanelRemote {
    @IsTest
    static void testBehavior() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        testData.ctp.Tasks_Are_Available__c = true;
        update testData.ctp;
        Boolean hasAccess;
 
        
        hasAccess = EmptyPagePanelRemote.getPermission(testData.ctp.Id, 'Trial_Surveys');
        Test.stopTest();
        //  System.assert(hasAccess);
    }
}
