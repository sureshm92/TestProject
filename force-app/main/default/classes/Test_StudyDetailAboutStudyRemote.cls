@IsTest(IsParallel=false)
public class Test_StudyDetailAboutStudyRemote {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    @IsTest
    static void basePITest1() {
        TestData testData = new TestData();
        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.piUser) {
            Test.startTest();
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_PI);
            StudyDetailViewController.getTrialDetail(
                testData.ctp.Id,
                CommunityService.USER_MODE_PI
            );
            StudyDetailAboutStudyRemote.setTrialAcceptedForPI(testData.ctp.Id, null, null);
            StudyDetailAboutStudyRemote.getDocuments(
                CommunityService.USER_MODE_PI,
                testData.ctp.Id
            );
            AccountSettingsController.getInitData(CommunityService.USER_MODE_HCP);
            AccountSettingsController.changeEmail('new@emil.com', CommunityService.USER_MODE_HCP);
            AccountSettingsController.changePassword('Dd231324d13', 'Dd231324d13', '11111');
            ClinicProfileRemote.getClinicProfileData(hcpAccount.Id);
            CommunityFacadeRemote.getCommunityData();
            CommunityFacadeRemote.changeMode(CommunityService.USER_MODE_PI, null, null, null);
        }
        Test.stopTest();
    }
    @IsTest
    static void basePITest2() {
        TestData testData = new TestData();
        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        testData.ss.Override_PI_Referral_Status__c = 'On Hold';
        update testData.ss;
        Resource__c docPtRes = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'TestRes'
        );
        insert docPtRes;
        Res_study__c resDocStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = docPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true,
            Visible_To_PI__c = true
        );
        insert resDocStudy;
        System.runAs(testData.piUser) {
            Test.startTest();
            StudyDetailAboutStudyRemote.setTrialAcceptedForPI(
                testData.ctp.Id,
                null,
                testData.ss.Id
            );
            StudyDetailAboutStudyRemote.getDocuments(
                CommunityService.USER_MODE_PI,
                testData.ctp.Id
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest3() {
        TestData testData = new TestData();
        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;

        testData.ss.Override_PI_Referral_Status__c = 'On Hold';
        update testData.ss;
        Resource__c docPtRes = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'TestRes'
        );
        insert docPtRes;
        Res_study__c resDocStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = docPtRes.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true,
            Visible_To_PI__c = true
        );
        ContentVersion contentVersion = new ContentVersion(
            LanguageCode__c = 'en_US',
            Title = 'en_US',
            PathOnClient = 'Irregular verbs.pdf',
            VersionData = EncodingUtil.base64Decode('fdsgg5465w')
        );
        insert contentVersion;
        insert resDocStudy;
        Id docId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'en_US'
            LIMIT 1
        ]
        .ContentDocumentId;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = docPtRes.Id
        );
        insert contentDocumentLink;
        Test.startTest();
        System.runAs(testData.piUser) {
            StudyDetailAboutStudyRemote.setTrialAcceptedForPI(
                testData.ctp.Id,
                null,
                testData.ss.Id
            );
            StudyDetailAboutStudyRemote.getDocuments(
                CommunityService.USER_MODE_PI,
                testData.ctp.Id
            );
        }
        Test.stopTest();
    }
    @IsTest
    static void basePITest4() {
        TestData testData = new TestData();
        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;

        testData.ss.Override_PI_Referral_Status__c = 'On Hold';
        update testData.ss;
        Test.startTest();
        System.runAs(testData.piUser) {
            StudyDetailAboutStudyRemote.setTrialAcceptedForPI(testData.ctp.Id, null, null);
        }
        Test.stopTest();
    }
}
