/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=true)
private class Test_DatabaseService {
    
    @IsTest
    static void databaseServiceText() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Test.startTest();
        List<Account> accounts = DatabaseService.query('SELECT Id FROM Account LIMIT 1');
        System.assert(accounts[0].Id == acc.Id);
        accounts = DatabaseService.query(
                new List<String>{
                        'Name'
                },
                Account.getSObjectType(),
                DatabaseService.fieldIn('Id', accounts)
        );
        System.assert(accounts[0].Id == acc.Id);
        Test.stopTest();
    }
}