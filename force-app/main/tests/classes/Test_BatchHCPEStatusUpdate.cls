/**
 * Created by Nikita Abrazhevitch on 13-Jan-20.
 */

@IsTest
private class Test_BatchHCPEStatusUpdate {
    @TestSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        Account piAccount = new Account(
                Name = 'PI Account'
        );
        accounts.add(piAccount);
        Account hcpAccount = new Account(
                Name = 'HCP Account'
        );
        accounts.add(hcpAccount);
        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509,
                BillingCountryCode = 'US'
        );
        accounts.add(studySiteAccount);
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        contacts.add(piContact);

        Contact hcpContact = new Contact(
                FirstName = 'HCP',
                LastName = 'HCP',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509
        );
        contacts.add(hcpContact);
        insert contacts;

        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA');
        insert area;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456789',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000001',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Therapeutic_Area__c = area.Id,
                Synch_with_TMDH__c = true,
                Include_in_RP_trial_search__c = true,
                Patient_Portal_Enabled__c = true
        );
        insert study;

        Study_Site__c studySite = new Study_Site__c(
                Primary_Key_ePR__c = 'tt123456789_US_123',
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = '123'
        );
        insert studySite;

        List<HCP_Enrollment__c> insertList = new List<HCP_Enrollment__c>();
        for (Integer i = 0; i < 100; i++) {
            insertList.add(new HCP_Enrollment__c(
                    Study_Site__c = studySite.Id,
                    HCP_Contact__c = hcpContact.Id,
                    Status__c = 'Activation Pending Orientation'));
        }
        insert insertList;
    }

    @IsTest
    static void testBehavior() {
        Test.startTest();
        Batch_HCPEStatusUpdate testBatch = new Batch_HCPEStatusUpdate();
        Database.executeBatch(testBatch);
        Test.stopTest();
        List<HCP_Enrollment__c> hcpList = [
                SELECT Id,
                        Status__c
                FROM HCP_Enrollment__c
                WHERE Status__c = :'Activation Pending Orientation'
        ];
        System.assertEquals(true, hcpList.isEmpty());
    }
}