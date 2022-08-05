@isTest
public class Batch_UpdatereminderdefaultvaluesTest {
    @isTest
    public static void test(){
        List<Terms_And_Conditions__c> tcList = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        tcList.add(portalTC);

        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        tcList.add(studyTC);
        insert tcList;
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
            userCommunytyType__c = 'PI',
            Participant_Phone_Opt_In_Permit_Phone__c = true,
            Participant_Opt_In_Status_Emails__c = true
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

        contact hcpContact = new Contact(
            FirstName = 'HCPTD',
            LastName = 'HCPTD',
            Email = 'hcp@emil.com',
            AccountId = hcpAccount.Id,
            MailingLatitude = 40.766594,
            MailingLongitude = -73.991509,
            userCommunytyType__c = CommunityService.USER_MODE_HCP,
            userCommunityMode__c = CommunityService.USER_MODE_HCP
        );
        contacts.add(hcpContact);
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
        list<Study_Site__c> sslist = new list<Study_Site__c>();
        Study_Site__c studySite = new Study_Site__c(
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
        sslist.add(studySite);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SwitchContactUserModeHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateHCPEnrollmentsForRPInWhiteListHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SetSuppressEmailsFieldAccordingToStudy.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.SetEnableCCSupportFieldAccordingToStudy.class );
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
        insert sslist;
        Batch_Updatereminderdefaultvalues batch = new Batch_Updatereminderdefaultvalues();
        database.executeBatch(batch, 200);
    }
}
