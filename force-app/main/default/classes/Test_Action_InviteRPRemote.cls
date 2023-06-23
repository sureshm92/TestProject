@IsTest(IsParallel=false)
public class Test_Action_InviteRPRemote {
     @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
         @IsTest
    static void basePITest5() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            Action_InviteRPRemote.getInviteDetail();
            Action_InviteRPRemote.inviteNewHCP(
                'test',
                'hcp',
                '12345',
                'test@mail.com.fake',
                null,
                'test-protocol',
                new List<String>()
            );
            Action_InviteRPRemote.inviteExistingHCP(
                [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com']
                .Id,
                null
            );
            Action_InviteRPRemote.SiteWrapper wrapper = new Action_InviteRPRemote.SiteWrapper(
                null,
                null
            );
            Action_InviteRPRemote.SiteWrapper wrapper2 = new Action_InviteRPRemote.SiteWrapper(
                null,
                null,
                null,
                null
            );
             Action_InviteRPRemote.PIOptionWrapper wrapper3 = new Action_InviteRPRemote.PIOptionWrapper(
                null,
                null
            );
        }
        Test.stopTest();
    }
        @IsTest
    static void testPIForInvetation() {
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
        Account usraccount;
        Contact usrcontact;
        System.runAs(admin) {
            usraccount = new Account(Name = 'Community');
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
      
            Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );

            insert SiteAccount;

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
                CommunityTemplate__c = CommunityTemplateService.TEMPLATE_DEFAULT,
                Suppress_Participant_Emails__c = false
            );
            insert clinical;

            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = usrcontact.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = usraccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Participant__c singleParticipant = (Participant__c) TestDataFactory.getSObject(
            Participant__c.getSObjectType(),
            new Map<String, Object>{
            'Contact__c' => usrcontact.Id,  // TODO Contact__c mustn't be piContact
            'First_Name__c' => 'ParticipantTD11',
            'Last_Name__c' => 'ParticipantTD12',
            'Phone__c' => '55313535',
            'Email__c' => 'someexample@gmail.com',
            'Mailing_Country_Code__c' => 'US',
            'Mailing_State_Code__c' => 'AL',
            'age__c' => 23,
            'site__c' => usraccount.Id
             });
            Site_Staff__c siteStaff = new Site_Staff__c(
                Delegate_Level__c = 'Level 1',
                Study_Site__c = studySite.Id,
                Site_Contact__c = usrcontact.Id
            );
            insert siteStaff;
          System.runAs(user_1) {
            Action_InviteRPRemote.getPIForInvetation(CommunityTemplateService.TEMPLATE_DEFAULT);
            Action_InviteRPRemote.checkDuplicate('some@email.com');
            System.assertNotEquals(singleParticipant.Email__c, 'some@email.com','Email is not matched');
        }
        Test.stopTest();
    }

}