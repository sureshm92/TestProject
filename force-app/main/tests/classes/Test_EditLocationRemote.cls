/**
 * Created by Nikita Abrazhevitch on 28-Aug-19.
 */

@IsTest
private class Test_EditLocationRemote {
    @IsTest
    static void getInitDataTest() {
        Action_EditLocationRemote.InitData initData = Action_EditLocationRemote.getInitData();
        System.assertNotEquals(null, initData);
    }

    @IsTest
    static void createTmpAccountForLocationCheckTest() {
        Account newAccount = new Account(
            BillingCountryCode = 'US',
            BillingCity = 'New York',
            BillingStreet = '170 William St',
            BillingStateCode = 'NY'
        );
        String stringAccount = Action_EditLocationRemote.createTmpAccountForLocationCheck(
            JSON.serialize(newAccount)
        );
        System.assertNotEquals(null, stringAccount);
    }

    @IsTest
    static void deleteTmpAccountTest() {
        Account newAccount = new Account(
            Name = 'TestAccountForDelete',
            BillingCountryCode = 'US',
            BillingCity = 'New York',
            BillingStreet = '170 William St',
            BillingStateCode = 'NY'
        );
        insert newAccount;
        Action_EditLocationRemote.deleteTmpAccount(newAccount.Id);
        List<Account> accList = [SELECT Id FROM Account WHERE Id = :newAccount.Id];
        System.assertEquals(0, accList.size());
    }

    @IsTest
    static void getTmpAccountTest() {
        Account newAccount = new Account(
            Name = 'TestAccountForDelete',
            BillingCountryCode = 'US',
            BillingCity = 'New York',
            BillingStreet = '170 William St',
            BillingStateCode = 'NY'
        );
        insert newAccount;
        Account testAcc = Action_EditLocationRemote.getTmpAccount(newAccount.Id);
        System.assertNotEquals(null, testAcc);
    }

    @IsTest
    static void upsertAccountTest() {
        //TestData.loadTestData();
        //TestData testData = new TestData();
		
        List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        //tcList.add(portalTC);
        Terms_And_Conditions__c ppTc = new Terms_And_Conditions__c(
            Active__c = true,
            Community_Name__c = 'IQVIA Referral Hub',
            Language__c = 'en_US',
            Last_Updated_on__c = 'July 10, 2020',
            Policy_Headers__c = 'Test Header 1',
            T_C_Text__c = '<p><b style="font-size: 12pt; font-family: Arial, sans-serif; color: rgb(0, 0, 0);">PRIVACY POLICY</b></p>',
            T_C_Type__c = 'Privacy Policy'
        );
        tcList.add(ppTc);
		
        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        tcList.add(studyTC);
        insert tcList;

        /*List<Terms_And_Conditions__c> ppList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c ppTc = new Terms_And_Conditions__c(
            Active__c = true,
            Community_Name__c = 'IQVIA Referral Hub',
            Language__c = 'en_US',
            Last_Updated_on__c = 'July 10, 2020',
            Policy_Headers__c = 'Test Header 1',
            T_C_Text__c = '<p><b style="font-size: 12pt; font-family: Arial, sans-serif; color: rgb(0, 0, 0);">PRIVACY POLICY</b></p>',
            T_C_Type__c = 'Privacy Policy'
        );
        ppList.add(ppTc);
        insert ppList;*/

        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        accounts.add(participantsAccount);

        Account piAccount = new Account(Name = 'PI Account', BillingCountry = 'United States');
        accounts.add(piAccount);

        Account hcpAccount = new Account(Name = 'HCP Account');
        accounts.add(hcpAccount);

        Account delegateAccount = new Account(
            Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        accounts.add(delegateAccount);

        Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountry = 'United States'
        );
        accounts.add(studySiteAccount);
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            Email = 'pi@emil.com',
            MailingCountry = 'United States',
            AccountId = piAccount.Id,
            userCommunytyType__c = 'PI'
        );
        contacts.add(piContact);
        insert contacts;

        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD');
        insert area;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'CTP1',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT99999999',
            Link_to_Pre_screening__c = 'some link',
            Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false,
            Therapeutic_Area__c = area.Id,
            Synch_with_TMDH__c = true,
            Include_in_RP_trial_search__c = true,
            Patient_Portal_Enabled__c = true,
            Shareback_Settings_On_Participant_Level__c = true,
            Shareback_Availability_Timing__c = 1,
            Visit_Data_Shareback__c = true,
            Visit_Schedule_Is_Available__c = true,
            Tasks_Are_Available__c = true,
            Study_Documents_Are_Available__c = true,
            Video_And_Articles_Are_Available__c = true,
            Travel_Vendor_Is_Available__c = true,
            Relevant_Links_Are_Available__c = true,
            Sponsor_Pays_for_Referral_Activity__c = 'Yes',
            CommunityTemplate__c = CommunityTemplateService.TEMPLATE_DEFAULT,
            Logged_Out_Days_Notification__c = 1,
            Enable_for_Call_Center_Support__c = true
        );
        insert study;

        List<PicklistEntry> pleList = Translation__c.Language__c.getDescribe().getPicklistValues();
        String langCode;
        for (PicklistEntry ple : pleList) {
            langCode = ple.getValue();
            if (TranslateHelper.isLanguageSupported(ple.getValue()))
                break;
        }
        Translation__c studyTranslation = new Translation__c(
            Language__c = langCode,
            Record_Id__c = study.Id,
            Field_Name__c = 'Study_Title__c',
            Value__c = 'Some translated value'
        );
        insert studyTranslation;

        Study_Site__c studySite1 = new Study_Site__c(
            Principal_Investigator__c = piContact.Id,
            Clinical_Trial_Profile__c = study.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SS1',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code',
            Enable_for_Call_Center_Support__c = true
        );
        insert studySite1;
        studySite1.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite1;	
        Test.startTest();
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c LIMIT 1];
        Account testAccount = new Account(
            Name = 'testAccount',
            BillingCountryCode = 'US',
            BillingCity = 'New York',
            BillingStreet = '170 William St',
            BillingStateCode = 'NY'
        );
        User piUser = [SELECT Id FROM User WHERE ContactId =:piContact.Id];
        System.runAs(piUser) {
            Account testAcc = Action_EditLocationRemote.upsertAccount(
                JSON.serialize(testAccount),
                studySite.Id
            );
            System.assertNotEquals(null, testAcc.Id);
            Account testSubAcc = Action_EditLocationRemote.upsertAccount(
                JSON.serialize(testAcc),
                studySite.Id
            );
            System.assertNotEquals(null, testSubAcc.ParentId);
            testSubAcc.Name = 'subAccount';
            Account updatedSubAccount = Action_EditLocationRemote.upsertAccount(
                JSON.serialize(testSubAcc),
                studySite.Id
            );
            System.assertEquals('subAccount', updatedSubAccount.Name);
        }
        Test.stopTest();
    }
}