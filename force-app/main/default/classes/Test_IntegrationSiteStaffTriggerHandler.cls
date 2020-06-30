@IsTest
private class Test_IntegrationSiteStaffTriggerHandler {

    @TestSetup
    static void setup() {
        TriggerHandlerExecutor.bypassHandler(SiteStaffTriggerHandler.RemoveConversationSharesHandler.class);
        TriggerHandlerExecutor.bypassHandler(SiteStaffTriggerHandler.RemoveConversationSharesHandler.class);

        Test.startTest();
        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;
        // ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');
        Test.stopTest();
        
    }

    @IsTest
    static void integration_Test(){
        Account piAccount = new Account(
            Name = 'PI Account',
            BillingCountry = 'United States'
        );
        insert piAccount;
        Contact piContact = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                Email = 'pi@emil.com',
                MailingCountry = 'United States',
                AccountId = piAccount.Id
        );
        insert piContact;
                Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD');
        insert area;
    Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
    insert studyTC;
        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = '1',
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
                Logged_Out_Days_Notification__c = 1
        );
        upsert study;
          Account acc = new Account(Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME);
        insert acc;
        Study_Site__c studySite = new Study_Site__c(
                Primary_Key_ePR__c = 'PK',
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Site__c = acc.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Billable_Code_CRM_Number__c = 'Test_Billable_Code'
        );
        insert studySite;
        studySite.Study_Site_Number__c = studySite.Id;
        update studySite;
               Account a = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        Contact delegateContact = (Contact) TestDataFactory.getSObject(Contact.getSObjectType(), new Map<String, Object>{
            'AccountId' => a.Id,
                'LastName' => 'portalTestUser1',
                'Email' => 'some@email.com'
                });
        Integration_Site_Staff__c externalSiteStaff = new Integration_Site_Staff__c();
        externalSiteStaff.protocolId__c = '1_2';
        externalSiteStaff.First_Name__c = 'Site';
        externalSiteStaff.Last_Name__c = 'Last_Name_Site';
        externalSiteStaff.Email__c = 'Dummy@fake.com';
        externalSiteStaff.Phone__c = '8200222';
        externalSiteStaff.Study_Site_Number__c = studySite.Id;
        externalSiteStaff.Site_Email_Key__c ='Dummy@fake1.com';
        externalSiteStaff.Roles__c = 'PRIMARY';
        // externalSiteStaff.Subject_Date__c = Date.today().addDays(1);
        // externalSiteStaff.IsDeletedInSDH__c = 'N';              
        insert delegateContact;        
        Site_Staff__c siteStaff = new Site_Staff__c();
        siteStaff.Site_Contact__c = delegateContact.Id;
        siteStaff.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1;
        siteStaff.Study_Site__c = studySite.Id;
        insert siteStaff;
        Test.startTest();
        Integration_Site_Staff__c externalSiteStaffDup = new Integration_Site_Staff__c();
        externalSiteStaffDup.protocolId__c = '1_2';
        externalSiteStaffDup.First_Name__c = 'Site1';
        externalSiteStaffDup.Last_Name__c = 'Last_Name_Site';
        externalSiteStaffDup.Email__c = 'Dummy@fake.com';
        externalSiteStaffDup.Phone__c = '8200222';
        externalSiteStaffDup.Study_Site_Number__c = studySite.Id;
        externalSiteStaffDup.Site_Email_Key__c ='Dummy@fake1.com';
        externalSiteStaffDup.Roles__c = 'PRIMARY';
        Site_Staff__c siteStaffnew = new Site_Staff__c();
        siteStaffnew.Site_Contact__c = delegateContact.Id;
        siteStaffnew.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1;
        siteStaffnew.Study_Site__c = studySite.Id;
        insert siteStaffnew;
        insert new List<Integration_Site_Staff__c>{externalSiteStaff,externalSiteStaffDup};
        IntegrationSiteStaffTriggerHandler.createSiteStaff(externalSiteStaff,siteStaff, studySite);
        IntegrationSiteStaffTriggerHandler.sendEmailNotification(piContact.Id);
        List<Contact> res = [SELECT Id FROM Contact WHERE FirstName ='Site1'];
        system.assertEquals(1,res.size());
        Test.stopTest();
    }
}