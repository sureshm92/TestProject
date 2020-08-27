@isTest
public class Test_Batch_UpdatePE_PermitEmailFlag {
@IsTest
    static void testBehavior() {
        
        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingCountry = 'United States'
        );
        
        insert studySiteAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States',
            AccountId = studySiteAccount.Id
        );
        insert piContact;
        Terms_And_Conditions__c tc = new Terms_And_Conditions__c(T_C_Text__c = 'T&C');
        insert tc;
        Terms_And_Conditions_Acceptance__c tca = new Terms_And_Conditions_Acceptance__c(Terms_And_Conditions__c = tc.id,
            Accepted_Date__c = system.TODAY());
        insert tca;
        Test.startTest();
        Database.executeBatch(new Batch_UpdatePE_PermitEmailFlag());
        Test.stopTest();
    }
}