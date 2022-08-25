@isTest
public class MotivationalMessageBatchDeletionTest {
	 @TestSetup
    static void init(){
        List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        tcList.add(portalTC);
        
        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        tcList.add(studyTC);
        insert tcList;
        
        List<Terms_And_Conditions__c> ppList = new List<Terms_And_Conditions__c>();
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
        insert ppList;
        
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
        
        Contact piDelegateContact = new Contact(
            FirstName = 'PIDelTD',
            LastName = 'PIDelTD',
            Email = 'pi_delegate@emil.com',
            AccountId = piAccount.Id,
            userCommunityMode__c = 'PI'
        );
        contacts.add(piDelegateContact);
        
        Contact hcpContact = new Contact(
            FirstName = 'HCPTD',
            LastName = 'HCPTD',
            Email = 'hcp@emil.com',
            AccountId = hcpAccount.Id,
            MailingLatitude = 40.766594,
            MailingLongitude = -73.991509,
            userCommunytyType__c = CommunityService.USER_MODE_HCP,
            userCommunityMode__c = CommunityService.USER_MODE_HCP
        );
        
        Contact hcpDelegateContact = new Contact(
            FirstName = 'HCPDelTD',
            LastName = 'HCPDelTD',
            Email = 'hcp_delegate@emil.com',
            AccountId = hcpAccount.Id
        );
        contacts.add(hcpDelegateContact);
        
        contacts.add(hcpContact);
        Contact ccContact = new Contact(
            FirstName = 'CCTD',
            LastName = 'CCTD',
            Email = 'cc@emil.com',
            AccountId = hcpAccount.Id,
            userCommunytyType__c = CommunityService.USER_MODE_CC,
            userCommunityMode__c = CommunityService.USER_MODE_CC
        );
        
        contacts.add(ccContact);
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
    }
    @isTest
    public static void testMotivationalMessageBatchDeletion(){
        Test.startTest();
        Clinical_Trial_Profile__c ctp = [SELECT id, Study_GUID__c FROM Clinical_Trial_Profile__c LIMIT 1];
        
        Motivational_Message__c mm = new Motivational_Message__c(Number_of_Days_Active_after_Enrollment__c = 0,Clinical_Trial_Profile__c = ctp.Id,Message__c = 'Message 1');
        insert mm;
                
        Database.executeBatch(new MotivationalMessageBatchDeletion(ctp.Id));
        Test.stopTest();
    }
}