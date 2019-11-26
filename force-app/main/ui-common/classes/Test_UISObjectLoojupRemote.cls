/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_UISObjectLoojupRemote {
    
    @IsTest
    static void test1() {
        Account acc =  new Account(Name = 'Test Acc');
        insert acc;
        UISobjectLookupRemote.searchSSByIds('Account', 'some', '', '');
        List<LookupSearchResult> resList = UISobjectLookupRemote.searchSSByTerm('Account', '', '', 'acc', '');
        System.assert(resList.size() > 0);
    }
    
}