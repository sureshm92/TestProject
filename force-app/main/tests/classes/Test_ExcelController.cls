/**
 * Created by Slav on 21.08.2019.
 */

@IsTest
public with sharing class Test_ExcelController {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    public static void runTest() {
        Test.StartTest();

        PageReference pageRef = Page.ExportExcelPage;
        pageRef.getParameters().put('userMode', CommunityService.USER_MODE_HCP); // USER_MODE_PARTICIPANT
        pageRef.getParameters().put('study', 'study');
        pageRef.getParameters().put('referringClinic', 'referringClinic');
        pageRef.getParameters().put('dateRange', 'dateRange');
        Test.setCurrentPage(pageRef);

        ExcelController excelController = new ExcelController();
        try {
            excelController.getPEList();
        } catch (Exception e) {
            // expected Exception
        }

        try {
            excelController.getHCPEList();
        } catch (Exception e) {
            // expected Exception
        }

        Test.StopTest();
    }

    @IsTest
    static void communityfilters() {
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        Account SiteAccount = new Account(Name = 'Study Site Account');

        insert SiteAccount;

        Contact con = new Contact(
            FirstName = 'PITD',
            LastName = 'PITD',
            AccountId = SiteAccount.Id,
            Email = 'part1@email.com'
        );
        insert con;

        Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false,
            Initial_Visit_Required__c = false
        );
        insert clinical;

        Study_Site__c studySite = new Study_Site__c(
            Name = 'Test',
            Principal_Investigator__c = con.Id,
            Clinical_Trial_Profile__c = clinical.Id,
            Site__c = SiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false
        );
        insert studySite;
        Participant__c participant = new Participant__c(
            First_Name__c = 'ParticipantTD',
            Last_Name__c = 'ParticipantTD',
            Phone__c = '55313535',
            Email__c = 'part1@email.com',
            Contact__c = con.Id,
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = SiteAccount.Id
        );
        insert participant;

        Participant_Enrollment__c pe2 = new Participant_Enrollment__c(
            Medical_Record_Review_Status__c = 'Pass',
            Pre_screening_Status__c = 'Pass',
            PI_Contact__c = con.Id,
            Study_Site__c = studySite.Id,
            Patient_ID__c = 'SomePatientId2',
            Referral_Source__c = 'PI',
            Initial_visit_occurred_flag__c = false,
            Participant__c = participant.Id,
            Screening_ID__c = 'PESCR2'
        );
        insert pe2;

        User user_1 = new User(
            Email = 'yourusername@gmail.com',
            UserName = 'yourusername@gmail.com',
            Alias = 'Test',
            ProfileId = profile_1.Id,
            TimeZoneSidKey = 'America/New_York',
            EmailEncodingKey = 'ISO-8859-1',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US',
            ContactId = con.Id,
            PortalRole = 'Manager',
            FirstName = 'Firstname',
            LastName = 'Lastname',
            isActive = true
        );
        insert user_1;

        String PERMISSION_COMMUNITY_JANSSEN_NAME = 'Community_Janssen';
        Set<String> permissionsgrp = new Set<String>();
        permissionsgrp.add(PERMISSION_COMMUNITY_JANSSEN_NAME);
        Action_AssignContactPermissions action = new Action_AssignContactPermissions();
        action.addPermission(con.Id, PERMISSION_COMMUNITY_JANSSEN_NAME);
        test.startTest();
        System.runAs(user_1) {
            ExcelController instance = new ExcelController();
            String exportedSObject = 'test';
            String result = instance.getCommunityFilter(exportedSObject);
        }
        Test.stopTest();
    }

    @IsTest
    static void testGetPEList() {
        TestData testData = new TestData();
        Test.startTest();

        PageReference pageRef = Page.ExportExcelPage;
        testData.ctp.Orientation_Required__c = true;
        update testData.ctp;
        pageRef.getParameters().put('userMode', CommunityService.USER_MODE_PI); // USER_MODE_PARTICIPANT
        pageRef.getParameters().put('study', testData.ctp.Id);
        pageRef.getParameters().put('referringClinic', null);
        pageRef.getParameters().put('dateRange', null);
        Test.setCurrentPage(pageRef);
        System.runAs(testData.piUser) {
            List<Participant_Enrollment__c> peList = new ExcelController().getPEList();
            System.assertEquals(6, peList.size());
            Test.stopTest();
        }
    }

    @IsTest
    static void testGetAllPEFieldList() {
        TestData testData = new TestData();
        Test.startTest();

        PageReference pageRef = Page.ExportExcelPage;
        testData.ctp.Orientation_Required__c = true;
        update testData.ctp;
        pageRef.getParameters().put('userMode', CommunityService.USER_MODE_PI); // USER_MODE_PARTICIPANT
        pageRef.getParameters().put('study', testData.ctp.Id);
        pageRef.getParameters().put('referringClinic', null);
        pageRef.getParameters().put('dateRange', null);
        Test.setCurrentPage(pageRef);
        System.runAs(testData.piUser) {
            ExcelController ec = new ExcelController();
            ec.getPEFieldsList();
            ExcelController.FieldWrapper fw = new ExcelController.FieldWrapper();
            fw.getFieldPath();
            fw.getLabel();
            Test.stopTest();
        }
    }
}
