@IsTest
public class Test_StudySiteTriggerHandler {
    @IsTest
    static void studySiteIntegrationte() {
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
        Contact usrcontact;
        System.runAs(admin) {
            Account usraccount = new Account(Name = 'Community');
            insert usraccount;
            
            usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek');
            insert usrcontact;
            
            user_1 = new User(
                Email = 'yourusername@gmail.com',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@gmail.com',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = usrcontact.Id,
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
                BillingCountry = 'United States',
                Org_Key__c = '22345'
            );
            insert SiteAccount;
            Account TMDHaccount = new Account(
                Name = 'TMDHAccount',
                BillingCountry = 'United States',
                Org_Key__c = '73887873'
            );
            
            insert TMDHaccount;
            
            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id
            );
            insert con;
            
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
            List<Study_Site__c>studyLST = new List<Study_Site__c>();
            Map<Id,Study_Site__c>studySiteMap = new Map<Id,Study_Site__c>();
            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = usrcontact.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false,
                Study_Site_Key__c = 'ACT367436'
            );
            insert studySite;
            studyLST.add(studySite);
            Site_Staff__c siteStaff = new Site_Staff__c(
                Delegate_Level__c = 'Level 1',
                Study_Site__c = studySite.Id,
                Site_Contact__c = con.Id
            );
            insert siteStaff;
            Study_Site__c tmdhstudySite = new Study_Site__c(
                Id = studySite.Id,
                Name = 'Test',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = TMDHaccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            tmdhstudySite.Billable_Code_CRM_Number__c = 'HAB08900';
            update tmdhstudySite;
            studySiteMap.put(studySite.Id,studySite);
            Assert.areNotEqual(tmdhstudySite, studySite, 'tmdhstudySite and studySite are equal.');
            StudySiteTriggerHandler.studySiteIntegration(studyLST,studySiteMap);
            
        }
        Test.stopTest();
    }
    
}