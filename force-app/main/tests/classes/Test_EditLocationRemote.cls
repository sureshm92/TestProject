/**
 * Created by Nikita Abrazhevitch on 28-Aug-19.
 */

@IsTest
private class Test_EditLocationRemote {

    @IsTest
    static void getInitDataTest(){
        Action_EditLocationRemote.InitData initData = Action_EditLocationRemote.getInitData();
        System.assertNotEquals(null, initData);
    }

    @IsTest
    static void createTmpAccountForLocationCheckTest() {
        Account newAccount = new Account(BillingCountryCode = 'US', BillingCity = 'New York', BillingStreet = '170 William St', BillingStateCode = 'NY');
        String stringAccount = Action_EditLocationRemote.createTmpAccountForLocationCheck(JSON.serialize(newAccount));
        System.assertNotEquals(null, stringAccount);
    }

    @IsTest
    static void deleteTmpAccountTest() {
        Account newAccount = new Account(Name='TestAccountForDelete', BillingCountryCode = 'US', BillingCity = 'New York', BillingStreet = '170 William St', BillingStateCode = 'NY');
        insert newAccount;
        Action_EditLocationRemote.deleteTmpAccount(newAccount.Id);
        List<Account> accList = [SELECT Id FROM Account WHERE Id =: newAccount.Id];
        System.assertEquals(0, accList.size());
    }

    @IsTest
    static void getTmpAccountTest() {
        Account newAccount = new Account(Name='TestAccountForDelete', BillingCountryCode = 'US', BillingCity = 'New York', BillingStreet = '170 William St', BillingStateCode = 'NY');
        insert newAccount;
        Account testAcc = Action_EditLocationRemote.getTmpAccount(newAccount.Id);
        System.assertNotEquals(null, testAcc);
    }

    @IsTest
    static void upsertAccountTest() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c LIMIT 1];
        Account testAccount = new Account(Name = 'testAccount', BillingCountryCode = 'US', BillingCity = 'New York', BillingStreet = '170 William St', BillingStateCode = 'NY');
        System.runAs(testData.piUser) {
            Account testAcc = Action_EditLocationRemote.upsertAccount(JSON.serialize(testAccount), studySite.Id);
            System.assertNotEquals(null, testAcc.Id);
            Account testSubAcc = Action_EditLocationRemote.upsertAccount(JSON.serialize(testAcc),studySite.Id);
            System.assertNotEquals(null, testSubAcc.ParentId);
            testSubAcc.Name = 'subAccount';
            Account updatedSubAccount = Action_EditLocationRemote.upsertAccount(JSON.serialize(testSubAcc),studySite.Id);
            System.assertEquals('subAccount', updatedSubAccount.Name);
        }
        Test.stopTest();
    }
}