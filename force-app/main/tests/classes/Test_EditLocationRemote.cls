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
        Test.startTest();
        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456789',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000001',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Participating_in_Digital_Recruitment__c = 'YES',
                Participating_in_Rocket_Referral__c = 'YES'
        );
        insert study;
        Account studySiteAccount = new Account(Name = 'studySiteAccount', BillingCountryCode = 'US', BillingCity = 'New York', BillingStreet = '170 William St', BillingStateCode = 'NY');
        insert studySiteAccount;
        Contact piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = studySiteAccount.Id
        );
        insert piContact;
        Study_Site__c studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
        );
        insert studySite;
        Account testAccount = new Account(Name = 'testAccount', BillingCountryCode = 'US', BillingCity = 'New York', BillingStreet = '170 William St', BillingStateCode = 'NY');
        Account testAcc = Action_EditLocationRemote.upsertAccount(JSON.serialize(testAccount),studySite.Id);
        System.assertNotEquals(null, testAcc.Id);
        Account testSubAcc = Action_EditLocationRemote.upsertAccount(JSON.serialize(testAcc),studySite.Id);
        System.assertNotEquals(null, testSubAcc.ParentId);
        testSubAcc.Name = 'subAccount';
        Account updatedSubAccount = Action_EditLocationRemote.upsertAccount(JSON.serialize(testSubAcc),studySite.Id);
        System.assertEquals('subAccount', updatedSubAccount.Name);
        Test.stopTest();
    }
}