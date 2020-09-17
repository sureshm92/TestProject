/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_CountryLookupRemote {

    @IsTest
    static void testAll() {
        TestData.loadTestData();
        TestData.createTCAcceptance();

        List<LookupSearchResult> testCountries;
        List<LookupSearchResult> testByValue;

        Test.startTest();
        TestData testData = new TestData();
        testCountries = CountryLookupRemote.searchCountries('','',true, false, testData.ctp.Id);
        testByValue = CountryLookupRemote.searchResultsByValue('US', true);
        Test.stopTest();

        System.assertEquals('United States', testCountries[0].title);
        System.assertEquals('United States', testByValue[0].title);
    }
}