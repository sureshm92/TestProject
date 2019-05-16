@IsTest(IsParallel=true)
public class Test_DatabaseProxy {

	@TestSetup
	static void setup() {
		Account singleAccount = new Account(Name='Test Account');
		insert singleAccount;
	}

	@IsTest
	static void query_Test() {
		DatabaseProxy databaseProxy = new DatabaseProxy();
		Test.startTest();
		List<Account> accounts = (List<Account>)databaseProxy.query('SELECT Id FROM Account');
		Test.stopTest();
		System.assertEquals(1, accounts.size());
	}

	@IsTest
	static void upsertRecord_Test() {
		Test.startTest();
		new DatabaseProxy().upsertRecord(new Account(Name='Test Account2'));
		Test.stopTest();
		List<Account> accounts = [SELECT Id, Name FROM Account];
		System.assertEquals(2, accounts.size());
		System.assert(accounts[0].Name.containsIgnoreCase('Test Account'));
	}

	@IsTest
	static void upsertRecords_Test() {
		Test.startTest();
		new DatabaseProxy().upsertRecords(new List<Account>{
				new Account(Name='Test Account2'),
				new Account(Name='Test Account3')
		});
		Test.stopTest();
		List<Account> accounts = [SELECT Id, Name FROM Account];
		System.assertEquals(3, accounts.size());
		System.assert(accounts[0].Name.containsIgnoreCase('Test Account'));
	}
}