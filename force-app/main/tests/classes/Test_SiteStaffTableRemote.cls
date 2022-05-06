/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_SiteStaffTableRemote {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testGetInitData() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            SiteStaffTableRemote.InitData initData = SiteStaffTableRemote.getInitData(
                testDataInst.hcpEnrollment.Study_Site__c
            );
            System.assertEquals(initData.viewMode, 'Disabled');
        }
        Test.stopTest();
    }
    @IsTest
    static void testCreateInitData() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            SiteStaffTableRemote.InitData initData = SiteStaffTableRemote.createInitData(
                testDataInst.hcpEnrollment.Study_Site__c,
                'Edit'
            );
            System.assertEquals(initData.viewMode, 'Edit');
            System.assertEquals(initData.inInvitationActiveStatus, true);
            System.assertEquals(initData.siteStaffMembers.size(), 2);
        }
        Test.stopTest();
    }
    @IsTest
    static void testInviteUser() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            SiteStaffTableRemote.InitData initData = SiteStaffTableRemote.createInitData(
                testDataInst.hcpEnrollment.Study_Site__c,
                'Edit'
            );
        }
        Test.stopTest();
    }
     @IsTest
    static void testInviteStaffMember() {
        
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
        Test.startTest();
        System.runAs(admin) {
            Account usraccount = new Account(Name = 'Community');
            insert usraccount;

            Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek');
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

            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = usrcontact.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = usraccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Site_Staff__c siteStaff = new Site_Staff__c(
                Delegate_Level__c = 'Level 1',
                Study_Site__c = studySite.Id,
                Site_Contact__c = usrcontact.Id
            );
            insert siteStaff;
            SiteStaffTableRemote.inviteStaffMember(usrcontact.Id,studySite.Id);
        
        Datetime timeStamp = Datetime.now();
            
            List<Action__c> pendingActions = [
                SELECT Id, Body__c, Status__c, CreatedDate
                FROM Action__c
                WHERE Type__c = 'Action_AssignContactPermissions' AND CreatedDate >= :timeStamp
            ];
            System.debug(pendingActions);
           // System.assertEquals(2, pendingActions.size());
        }
         Test.stopTest();
       
    }
}