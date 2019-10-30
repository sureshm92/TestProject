/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_VisitResultCountryLookupRemote {

    @IsTest
    static void testAll() {
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.startTest();
        TestData testData = new TestData();
        VisitResultSharingCountryLookupRemote.searchCountries('','',true, false, testData.ctp.Id);
        VisitResultSharingCountryLookupRemote.searchResultsByValue('US', true);
        Test.stopTest();
    }
}