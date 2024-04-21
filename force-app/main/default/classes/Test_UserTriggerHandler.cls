@IsTest
public class Test_UserTriggerHandler {
	@TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        
        TestData testData = new TestData();
        List<Survey> survey = [SELECT Id, Name FROM Survey WHERE ActiveVersionId != NULL LIMIT 1];
        if (!survey.isEmpty()){
            Id communityId = CommunityService.getCommunityId(null);
            List<SurveyInvitation> invitations = new List<SurveyInvitation>();
            invitations.add(
                SurveyService.getInstance()
                    .generateInvitation(survey.get(0), null, 5, false, testData.pe.Id, communityId)
            );
            invitations.add(
                SurveyService.getInstance()
                    .generateInvitation(survey.get(0), null, 10, false, testData.pe.Id, communityId)
            );
            invitations.add(
                SurveyService.getInstance()
                    .generateInvitation(survey.get(0), null, 15, false, testData.pe.Id, communityId)
            );
            insert invitations;
        }
            

                
        
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        
        Account usraccount = new Account(Name = 'Community');
        insert usraccount;
        
        Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek');
        insert usrcontact;
        
        User user_1 = new User(
                Email = 'yourusername@test.com.invalid',
                ProfileId = profile_1.Id,
                UserName = 'yourusername@test.com.invalid',
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
        Test.stopTest();
        
    }
    
    @IsTest
    static void userTrigger1() {
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
        Contact usrcontact = [select Id from contact where lastname = 'xgeek' limit 1];
        User admin = [
            SELECT Id, Username, UserRoleId
            FROM User
            WHERE
                Profile.Name = 'System Administrator'
                AND UserRoleId = :userRole_1.Id
                AND IsActive = TRUE
            LIMIT 1
        ];
        System.runAs(admin) {
            User user_1 = [select Id from user where contactId = :usrcontact.Id];
            user_1.firstname = 'Tentus';
            user_1.email = 'Test@invalid.com';
            user_1.LocaleSidKey = 'en_GB';
            user_1.LanguageLocaleKey = 'en_GB';
            update user_1;
        }
    }
    
    @IsTest
    static void userTrigger2() {
      
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        
        Account usraccount = new Account(Name = 'Community2');
        insert usraccount;
        
        Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek2');
        insert usrcontact;
        
      
        Task task = new Task();
        task.Owner_Contact__c = usrcontact.Id;
        
        insert task;
        
        User user_1 = new User(
                Email = 'testi@test.com.invalid',
                ProfileId = profile_1.Id,
                UserName = 'testi@test.com.invalid',
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
    @IsTest
    static void userTrigger3() {
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        
        Study_Site__c studySite = [
            SELECT Id
            FROM Study_Site__c
            WHERE Study_Site_Number__c = 'SS1'
            LIMIT 1
        ];
        
        Account piAccount = [select Id from account where name ='PI Account' limit 1];
        Contact piContact = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                Email = 'pi2@emil.com.invalid',
                MailingCountry = 'United States',
                AccountId = piAccount.Id,
                userCommunytyType__c = 'PI'
            );
		insert piContact;
        
        User user_1 = new User(
                Email = 'testi@test.com.invalid',
                ProfileId = profile_1.Id,
                UserName = 'testi@test.com.invalid',
                Alias = 'Test',
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ContactId = piContact.Id,
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname'
            );
        insert user_1;
        
    }
    
}