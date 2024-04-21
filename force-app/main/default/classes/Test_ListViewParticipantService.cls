@IsTest(IsParallel=false)
public class Test_ListViewParticipantService {
    @IsTest
    static void testgetPEFilterDataWith() {
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        insert portalTC;

        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert participantsAccount;

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
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
        System.runAs(admin) {
            Account account_1 = new Account(Name = 'Community');
            insert account_1;

            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_1;

            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;

            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id,
                Email = 'test@con.com'
            );
            insert con;

            Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>();
            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false
            );
            insert clinical;
            trialsMap.put(clinical.ID, clinical);
            List<Study_Site__c> studySites = new List<Study_Site__c>();

            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Study_Site_Phone__c = '0000034445',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            studySites.add(studySite);
            try {
                ListViewParticipantService.getPEFilterDataWithSponsor(
                    'PI',
                    clinical.ID,
                    true,
                    con.Id,
                    'Janssen'
                );
            } catch (exception e) {
            }
            try {
                ListViewParticipantService.createPEFilterDataForTrials(trialsMap, studySites, 'PI');
            } catch (exception e) {
            }
        }
    }
	@IsTest
    static void testgetPEFilterDataWith1() {
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(Active__c = true);
        insert portalTC;

        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
            Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        insert participantsAccount;

        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
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
        System.runAs(admin) {
            Account account_1 = new Account(Name = 'Community');
            insert account_1;

            Contact contact_1 = new Contact(AccountId = account_1.Id, LastName = 'xgeek');
            insert contact_1;

            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = contact_1.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
            insert user_1;
        }
        Test.startTest();
        System.runAs(user_1) {
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;

            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id,
                Email = 'test@con.com'
            );
            insert con;

            Map<Id, Clinical_Trial_Profile__c> trialsMap = new Map<Id, Clinical_Trial_Profile__c>();
            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false
            );
            insert clinical;
            trialsMap.put(clinical.ID, clinical);
            List<Study_Site__c> studySites = new List<Study_Site__c>();

            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Study_Site_Phone__c = '0000034445',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            studySites.add(studySite);
            try {
                ListViewParticipantService.getPEFilterDataWithSponsor(
                    'HCP',
                    clinical.ID,
                    true,
                    con.Id,
                    'Janssen'
                );
            } catch (exception e) {
            }
            try {
                ListViewParticipantService.createPEFilterDataForTrials(trialsMap, studySites, 'PI');
            } catch (exception e) {
            }
        }
    }
}
