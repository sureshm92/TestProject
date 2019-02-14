/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_CommunityUserOnStudySite {


    static testMethod void test1() {
        Account acc1 = new Account(
                Name = 'newAcc1'
        );
        insert acc1; 

        Contact piContact = new Contact(
                AccountId = acc1.Id,
                LastName = 'portalTestUser1',
                Email = 'some@email.com'
        );
        insert piContact;



        Clinical_Trial_Profile__c clinicalTrialProfile = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'test protocol Id',
                Study_Title__c = 'Test Study',
                Study_Code_Name__c = 'Test Study Code Name',
                NCT_Number__c = 'NCT00000000'
        );
        insert clinicalTrialProfile;

        Study_Site__c studySite = new Study_Site__c(
                Name = 'Test Study 2',
                Clinical_Trial_Profile__c = clinicalTrialProfile.Id,
                Site__c = acc1.Id,
                Principal_Investigator__c = piContact.Id
        );
        insert studySite;

        Contact piContact1 = [SELECT userCommunityMode__c, userCommunytyType__c FROM Contact WHERE Id =: piContact.Id];
        System.assertEquals('PI', piContact1.userCommunityMode__c);
        System.assertEquals(true, piContact1.userCommunytyType__c.contains('PI'));

        piContact1.userCommunytyType__c = 'HCP';
        update piContact1;

        Account acc2 = new Account(
                Name = 'newAcc2'
        );
        insert acc2;

        Study_Site__c studySite2 = new Study_Site__c(
                Name = 'Test Study 3',
                Clinical_Trial_Profile__c = clinicalTrialProfile.Id,
                Site__c = acc2.Id,
                Study_Site_Key__c = '111',
                Principal_Investigator__c = piContact.Id
        );
        insert studySite2;

        Contact piContact2 = [SELECT userCommunityMode__c, userCommunytyType__c FROM Contact WHERE Id =: piContact.Id];    
        System.assertEquals(true, piContact2.userCommunytyType__c.contains('PI'));
    }

 }