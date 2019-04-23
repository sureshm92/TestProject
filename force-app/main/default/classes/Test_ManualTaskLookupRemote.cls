/**
 * Created by Igor Malyuta on 22.04.2019.
 */

@IsTest
private class Test_ManualTaskLookupRemote {

    @IsTest
    static void searchTherapeuticTest() {
        Therapeutic_Area__c ta = new Therapeutic_Area__c(Name = 'Test Area');
        insert ta;
        List<String> taId = new List<String>();
        taId.add(ta.Id);

        Therapeutic_Area__c ta2 = new Therapeutic_Area__c(Name = 'Test Area 2');
        insert ta2;

        Test.startTest();
        List<LookupSearchResult> lookupSearchResults = ManualTaskLookupRemote.searchTherapeutic('Test Area 2', taId);
        Test.stopTest();

        LookupSearchResult testResult =
                new LookupSearchResult(ta2.Id, 'Therapeutic_Area__c', 'custom:custom18', ta2.Name, '');

        assertThat(testResult, lookupSearchResults);
    }

    @IsTest
    static void searchSponsorTest() {
        Account accountPartic = new Account(Name = 'Participant');
        insert accountPartic;
        List<String> accId = new List<String>();
        accId.add(accountPartic.Id);

        Test.startTest();
        List<LookupSearchResult> lookupSearchResults = ManualTaskLookupRemote.searchSponsor('Participant', accId);
        Test.stopTest();

        LookupSearchResult testResult =
                new LookupSearchResult(accountPartic.Id, 'Account', 'standard:account', accountPartic.Name, '');

        assertThat(testResult, lookupSearchResults);
    }

    @IsTest
    static void searchCountriesTest() {

    }

    @IsTest
    static void searchStudyTest() {

    }

    @IsTest
    static void searchSiteTest() {

    }

    private static void assertThat(LookupSearchResult testResult, List<LookupSearchResult> lookupSearchResults) {
        System.assertEquals(testResult.getId(), lookupSearchResults.get(0).getId());
        System.assertEquals(testResult.getSObjectType(), lookupSearchResults.get(0).getSObjectType());
        System.assertEquals(testResult.getIcon(), lookupSearchResults.get(0).getIcon());
        System.assertEquals(testResult.getTitle(), lookupSearchResults.get(0).getTitle());
        System.assertEquals(testResult.getSubtitle(), lookupSearchResults.get(0).getSubtitle());
    }
}