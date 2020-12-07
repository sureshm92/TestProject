/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_VisitResultCountryLookupRemote {
    @IsTest
    static void testAll() {
        List<LookupSearchResult> testCountries;
        List<LookupSearchResult> testResultsByValue;
        TestData.loadTestData();
        TestData.createTCAcceptance();

        Test.startTest();
        TestData testData = new TestData();
        testCountries = VisitResultSharingCountryLookupRemote.searchCountries(
            '',
            '',
            true,
            false,
            testData.ctp.Id,
            ''
        );
        testResultsByValue = VisitResultSharingCountryLookupRemote.searchResultsByValue(
            'US',
            true,
            ''
        );
        Test.stopTest();

        System.assertEquals('United States', testCountries[0].title);
        System.assertEquals('United States', testResultsByValue[0].title);
    }
}
