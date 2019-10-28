/**
 * Created by Krivo on 26.10.2019.
 */

@IsTest
private class Test_CountryLookupRemote {

    @IsTest
    static void testAll() {
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.startTest();
        TestData testData = new TestData();
        CountryLookupRemote.searchCountries('','',true, false, testData.ctp.Id);
        CountryLookupRemote.searchResultsByValue('US', true);
        Test.stopTest();
    }
}