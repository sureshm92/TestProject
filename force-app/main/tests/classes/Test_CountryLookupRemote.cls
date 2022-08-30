/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_CountryLookupRemote {
    @IsTest
    static void testAll() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        TestData.createTCAcceptance();

        List<LookupSearchResult> testCountries;
        List<LookupSearchResult> testByValue;

        
        TestData testData = new TestData();
        testCountries = CountryLookupRemote.searchCountries('', '', true, false, testData.ctp.Id);
        testByValue = CountryLookupRemote.searchResultsByValue('US', true);
        

        System.assertEquals('United States', testCountries[0].title);
        System.assertEquals('United States', testByValue[0].title);
    }
}