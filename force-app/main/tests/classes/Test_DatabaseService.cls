/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=true)
private class Test_DatabaseService {
    @IsTest
    static void databaseServiceText() {
        // TestData.loadTestData();
        //TestData testdata = new TestData();
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Test.startTest();
        List<Account> accounts = DatabaseService.query('SELECT Id FROM Account LIMIT 1');
        System.assert(accounts[0].Id == acc.Id);
        accounts = DatabaseService.query(
            new List<String>{ 'Name' },
            Account.getSObjectType(),
            DatabaseService.fieldIn('Id', accounts)
        );
        System.assert(accounts[0].Id == acc.Id);
        List<String> values = new List<String>();
        String field;
        String value;
        List<SObject> sObjects = new List<SObject>();
        DatabaseService.listToString(values);
        DatabaseService.fieldEqual(field, value);
        DatabaseService.DatefieldEqualsNull(field);
        DatabaseService.DatefieldNotEqualsNull(field);
        DatabaseService.fieldNotEqual(field, value);
        DatabaseService.fieldNotIn(field, sObjects);
        DatabaseService.fieldInValues(field, values);
        DatabaseService.fieldNotInValues(field, values);
        DatabaseService.fieldLike(field, value);
        Test.stopTest();
    }
}
