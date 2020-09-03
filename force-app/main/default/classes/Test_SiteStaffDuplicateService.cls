@IsTest
public class Test_SiteStaffDuplicateService {
    @IsTest
    static void test() {
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
                Logged_Out_Days_Notification__c = 1
        );
        insert study;
          Account acc = new Account(Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME);
        insert acc;
        Study_Site__c studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Site__c = acc.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Number__c = 'SS1',
                Billable_Code_CRM_Number__c = 'Test_Billable_Code'
        );
        insert studySite;
        
               Account a = (Account) TestDataFactory.getSObject(Account.getSObjectType());
        Contact delegateContact = (Contact) TestDataFactory.getSObject(Contact.getSObjectType(), new Map<String, Object>{
            'AccountId' => a.Id,
                'LastName' => 'portalTestUser1',
                'Email' => 'some@email.com'
                });
        insert delegateContact;    
        Test.startTest();
        Site_Staff__c siteStaffWithBY = new Site_Staff__c();
        siteStaffWithBY.Site_Contact__c = delegateContact.Id;
        siteStaffWithBY.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1;
        siteStaffWithBY.Study_Site__c = studySite.Id;
        siteStaffWithBY.Email__c = 'MaxJames@mail.com';
        insert siteStaffWithBY;
        
        Site_Staff__c siteStaffWithoutBY = new Site_Staff__c();
        siteStaffWithoutBY.Site_Contact__c = delegateContact.Id;
        siteStaffWithoutBY.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1;
        siteStaffWithoutBY.Study_Site__c = studySite.Id;
        siteStaffWithoutBY.Email__c = 'MaxJames@mail.com';
        siteStaffWithoutBY.Phone__c = '123456789';
        insert siteStaffWithoutBY;
        Site_Staff__c siteStaffDiffPhonesSameEmails = new Site_Staff__c();
        siteStaffDiffPhonesSameEmails.Site_Contact__c = delegateContact.Id;
        siteStaffDiffPhonesSameEmails.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1;
        siteStaffDiffPhonesSameEmails.Study_Site__c = studySite.Id;
        siteStaffDiffPhonesSameEmails.Email__c = 'diffphones@mail.com';
        siteStaffDiffPhonesSameEmails.Phone__c = '7777777';
        insert siteStaffDiffPhonesSameEmails;
        Site_Staff__c siteStaffSamePhonesSameEmails = new Site_Staff__c();
        siteStaffSamePhonesSameEmails.Site_Contact__c = delegateContact.Id;
        siteStaffSamePhonesSameEmails.Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1;
        siteStaffSamePhonesSameEmails.Study_Site__c = studySite.Id;
        siteStaffSamePhonesSameEmails.Email__c = 'diffphones@mail.com';
        siteStaffSamePhonesSameEmails.Phone__c = '7777777';
        insert siteStaffSamePhonesSameEmails;
        SiteStaffDuplicateService.DuplicateContainer dc = new SiteStaffDuplicateService.DuplicateContainer(siteStaffSamePhonesSameEmails);
        dc.getFirstName();
        dc.getContact();
        SiteStaffDuplicateService duplicateService = new SiteStaffDuplicateService(new List<Site_Staff__c>{
                siteStaffWithBY,
                siteStaffWithoutBY,
                siteStaffDiffPhonesSameEmails,
                siteStaffSamePhonesSameEmails
        });
        duplicateService.findDuplicate(siteStaffSamePhonesSameEmails);
        duplicateService.findDuplicateContact(siteStaffSamePhonesSameEmails);
        Test.stopTest();
    }
}