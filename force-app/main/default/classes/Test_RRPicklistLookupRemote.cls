/**
 * Created by Nargiz Mamedova on 3/27/2020.
 */

@IsTest
private class Test_RRPicklistLookupRemote {
    @IsTest
    static void testBehavior() {
        List<LookupSearchResult> lookupSearchResults;
        Test.startTest();
        lookupSearchResults = RRPicklistLookupRemote.getAllValues('Resource__c', 'Type__c', 'custom:custom31');
        Test.stopTest();
        System.assert(lookupSearchResults.size() > 0);
    }

    @IsTest
    static void testException(){
        Boolean isExceptionThrown = false;
        List<LookupSearchResult> lookupSearchResults;
        Test.startTest();
        try {
            lookupSearchResults = RRPicklistLookupRemote.getAllValues(null, null, null);
        } catch (Exception e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}