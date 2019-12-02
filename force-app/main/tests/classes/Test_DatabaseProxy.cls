@IsTest(IsParallel=true)
public class Test_DatabaseProxy {

    @IsTest
    static void query_Test() {
        Account singleAccount = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert singleAccount;
        DatabaseProxy databaseProxy = new DatabaseProxy();
        Test.startTest();
        List<Account> accounts = (List<Account>) databaseProxy.query('SELECT Id FROM Account');
        List<Account> accountsWithoutSharing = (List<Account>) databaseProxy.query('SELECT Id FROM Account', true);
        List<Account> accountsWithSharing = (List<Account>) databaseProxy.query('SELECT Id FROM Account', false);
        Test.stopTest();
        System.assertEquals(1, accounts.size());
        System.assertEquals(1, accountsWithoutSharing.size());
        System.assertEquals(1, accountsWithSharing.size());
    }

    @IsTest
    static void upsertRecord_Test() {
        DatabaseProxy databaseProxy = new DatabaseProxy();
        Test.startTest();
        databaseProxy.upsertRecord(TestDataFactory.getSObject(Account.getSObjectType()), true);
        databaseProxy.upsertRecord(TestDataFactory.getSObject(Account.getSObjectType()), false);
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    static void upsertRecords_Test() {
        DatabaseProxy databaseProxy = new DatabaseProxy();
        Test.startTest();
        databaseProxy.upsertRecords(new List<Account>{
                (Account) TestDataFactory.getSObject(Account.getSObjectType()),
                (Account) TestDataFactory.getSObject(Account.getSObjectType())
        }, true);
        databaseProxy.upsertRecords(new List<Account>{
                (Account) TestDataFactory.getSObject(Account.getSObjectType()),
                (Account) TestDataFactory.getSObject(Account.getSObjectType())
        }, false);
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(4, accounts.size());
    }

    @IsTest
    static void updateRecord_Test() {
        DatabaseProxy databaseProxy = new DatabaseProxy();
        Account accountToUpdate = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert accountToUpdate;
        accountToUpdate.Name = 'New Name';
        Test.startTest();
        databaseProxy.updateRecord(accountToUpdate, true);
        databaseProxy.updateRecord(accountToUpdate, false);
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, accounts.size());
        System.assertEquals('New Name', accountToUpdate.Name);
    }

    @IsTest
    static void updateRecords_Test() {
        DatabaseProxy databaseProxy = new DatabaseProxy();
        Account accountToUpdate = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert accountToUpdate;
        accountToUpdate.Name = 'New Name';
        Test.startTest();
        databaseProxy.updateRecords(new List<SObject>{
                accountToUpdate
        }, true);
        databaseProxy.updateRecords(new List<SObject>{
                accountToUpdate
        }, false);
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assertEquals(1, accounts.size());
        System.assertEquals('New Name', accountToUpdate.Name);
    }

    @IsTest
    static void deleteRecord_Test() {
        DatabaseProxy databaseProxy = new DatabaseProxy();
        Account firstAccountToDelete = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert firstAccountToDelete;
        Account secondAccountToDelete = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert secondAccountToDelete;
        firstAccountToDelete.Name = 'New Name';
        secondAccountToDelete.Name = 'New Name';
        Test.startTest();
        databaseProxy.deleteRecord(firstAccountToDelete, true);
        databaseProxy.deleteRecord(secondAccountToDelete, false);
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assert(accounts.isEmpty());
    }

    @IsTest
    static void deleteRecords_Test() {
        DatabaseProxy databaseProxy = new DatabaseProxy();
        Account firstAccountToDelete = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert firstAccountToDelete;
        Account secondAccountToDelete = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        insert secondAccountToDelete;
        firstAccountToDelete.Name = 'New Name';
        secondAccountToDelete.Name = 'New Name';
        Test.startTest();
        databaseProxy.deleteRecords(new List<SObject>{
                firstAccountToDelete
        }, true);
        databaseProxy.deleteRecords(new List<SObject>{
                secondAccountToDelete
        }, false);
        Test.stopTest();
        List<Account> accounts = [SELECT Id, Name FROM Account];
        System.assert(accounts.isEmpty());
    }
}