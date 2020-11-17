@isTest
public class Test_Batch_UpdateJanssenctCookies {
    @isTest
    private static void updateJanssenctCookies (){
      Account account_1 = new Account(Name = 'Community',  BillingCountry = 'United States');
            insert account_1;
            
          contact  contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_1;
            contact_1.RRJanssenCookiesAllowedCookie__c = false;
            update contact_1;
           Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                CommunityTemplate__c = 'Janssen',
                Suppress_Participant_Emails__c = false);
            insert clinical;
            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Study_Site_Phone__c = '0000034445',
                Principal_Investigator__c = contact_1.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = account_1.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false);
            insert studySite;
          Test.startTest();      
        Database.executeBatch(new Batch_UpdateJanssenctCookies()); 
           Test.stopTest();
        contact_1 = [SELECT RRJanssenCookiesAllowedCookie__c FROM Contact WHERE id=: contact_1.id];
           
        System.assertEquals(true, contact_1.RRJanssenCookiesAllowedCookie__c);   
        
    }
}