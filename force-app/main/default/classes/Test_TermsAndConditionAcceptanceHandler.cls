@isTest
private class Test_TermsAndConditionAcceptanceHandler {
     @isTest
    static void test() {
         TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.StudySiteTriggerHandler.class
        );

         UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
         Terms_And_Conditions__c ppTc = new Terms_And_Conditions__c(
            Active__c = true,
            Community_Name__c = 'IQVIA Referral Hub',
            Language__c = 'en_US',
            Last_Updated_on__c = 'July 10, 2020',
            Policy_Headers__c = 'Test Header 1',
            T_C_Text__c = '<p><b style="font-size: 12pt; font-family: Arial, sans-serif; color: rgb(0, 0, 0);">PRIVACY POLICY</b></p>',
            T_C_Type__c = 'Privacy Policy'
        );
        insert ppTc;

        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        User admin = [
            SELECT Id, Username, UserRoleId
            FROM User
            WHERE
                Profile.Name = 'System Administrator'
                AND UserRoleId = :userRole_1.Id
                AND IsActive = TRUE
            LIMIT 1
        ];

        User user_1;
        Contact piContact;
        System.runAs(admin) {
            Account studySiteAccount = new Account(
            Name = 'Study Site Account',
            BillingLatitude = 41.766594,
            BillingLongitude = -74.991509,
            BillingCountry = 'United States'
        );
        insert studySiteAccount;
             piContact = new Contact(
                AccountId = studySiteAccount.Id,
                LastName = 'ParticipantTD12',
                FirstName = 'ParticipantTD11',
                Email = 'someexample@gmail.com',
                userCommunytyType__c = 'PI'
            );
            insert piContact;
            user_1 = new User(
                Email = 'someexample@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = piContact.Id,
                PortalRole = 'Manager',
                FirstName = 'ParticipantTD11',
                LastName = 'ParticipantTD12'
            );
            insert user_1;
             Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA TD');
        insert area;

        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'CTP1',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT99999999',
            Link_to_Pre_screening__c = 'some link',
            Terms_And_Conditions_ID__c = ppTc.Id,
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
             Terms_And_Conditions_Acceptance__c tcAcceptance = new Terms_And_Conditions_Acceptance__c(
            Terms_And_Conditions__c = ppTc.id,
            User__c = user_1.id,
            Accepted_Date__c = Date.today()
        );
        insert tcAcceptance;
        
        Test.startTest();
        TermsAndConditionAcceptanceHandler.handleAcceptance(new list<Terms_And_Conditions_Acceptance__c>{tcAcceptance});
        Test.stopTest();
 
        }
    }
}