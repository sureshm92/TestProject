/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_BaseCRCPCommunity {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }

    @IsTest
    static void testReferralNetworkService_AutoEmails() {
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Therapeutic_Area__c area = [SELECT Id FROM Therapeutic_Area__c WHERE Name = 'Test TA TD'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        Account studySiteAccount = [SELECT Id FROM Account WHERE Name = 'Study Site Account'];
        Referral_Network__c referralNetwork = [
            SELECT Id
            FROM Referral_Network__c
            WHERE Name = 'Test Referral Network'
        ];
        Clinical_Trial_Profile__c testStudy = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'tt123456790',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT00000002',
            Link_to_Pre_screening__c = 'some link',
            Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false,
            Therapeutic_Area__c = area.Id
        );
        insert testStudy;
        Test.startTest();
        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = hcpContact.Id,
            Clinical_Trial_Profile__c = testStudy.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            ReferralNetworkId__c = referralNetwork.Id
        );
        insert studySite;

        Test.stopTest();
    }

    @IsTest
    static void testReferralNetworkService_Subscription() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.hcpUser) {
            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> recordsRN = SubscribeToReferralNetworkRemote.getReferralNetworkRecords(
                'Referral_Network__c'
            );
            SubscribeToReferralNetworkRemote.searchForReferralNetworks(
                recordsRN[0].Name,
                'Referral_Network__c'
            );
            SubscribeToReferralNetworkRemote.deleteAndGetRefferalNetworks(
                'Referral_Network__c',
                new List<Id>{ recordsRN[0].Id }
            );

            SubscribeToReferralNetworkRemote.ReferralNetworkWrapper newRecordRN = new SubscribeToReferralNetworkRemote.ReferralNetworkWrapper();
            newRecordRN.Id = recordsRN[0].Id;
            newRecordRN.isSelected = true;
            SubscribeToReferralNetworkRemote.saveReferralNetworks(JSON.serialize(newRecordRN));
            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> newRecRNs = new List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper>();
            newRecRNs.add(newRecordRN);
            SearchConditionsOfInterestRemote.saveReferralNetworksNew(JSON.serialize(newRecRNs));

            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> recordsTA = SubscribeToReferralNetworkRemote.getReferralNetworkRecords(
                'Therapeutic_Area__c'
            );
            SubscribeToReferralNetworkRemote.searchForReferralNetworks(
                recordsTA[0].Name,
                'Therapeutic_Area__c'
            );
            SubscribeToReferralNetworkRemote.deleteAndGetRefferalNetworks(
                'Referral_Network__c',
                new List<Id>{ recordsTA[0].Id }
            );

            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> newRecTAs = new List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper>();
            SubscribeToReferralNetworkRemote.ReferralNetworkWrapper newRecordTA = new SubscribeToReferralNetworkRemote.ReferralNetworkWrapper();
            newRecordTA.Id = recordsTA[0].Id;
            newRecordTA.isSelected = true;
            newRecTAs.add(newRecordTA);

            SubscribeToReferralNetworkRemote.saveReferralNetworks(JSON.serialize(newRecordTA));
            SearchConditionsOfInterestRemote.saveReferralNetworksNew(JSON.serialize(newRecTAs));

            // SubscribeToReferralNetworkRemote.saveReferralNetworksNew(JSON.serialize(newRecTAs));
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPAdvancedTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.hcpUser) {
            String stringData = StudyListViewController.getHCPInitData(null);
            StudyListViewController.HCPInitData initData = (StudyListViewController.HCPInitData) JSON.deserializeStrict(
                stringData,
                StudyListViewController.HCPInitData.class
            );
            StudyListViewController.searchStudies(
                JSON.serialize(initData.filterData),
                JSON.serialize(initData.sortData),
                JSON.serialize(initData.paginationData),
                false
            );
            StudyListViewController.searchStudies(
                JSON.serialize(initData.filterData),
                JSON.serialize(initData.sortData),
                JSON.serialize(initData.paginationData),
                true
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testStudyDetailItem() {
        StudyDetailItem sdi1 = new StudyDetailItem();
        sdi1.maxHCPCreatedDate = Datetime.now();
        sdi1.sites = new List<StudySiteService.StudySiteDistanceWrapper>();
        sdi1.studyActions = new List<StudyActions.Action>();

        StudySiteService.StudySiteDistanceWrapper site1 = new StudySiteService.StudySiteDistanceWrapper();
        site1.distance = 12;
        sdi1.sites.add(site1);

        StudyDetailItem sdi2 = new StudyDetailItem();
        sdi2.maxHCPCreatedDate = Datetime.now().addDays(-100);
        sdi2.sites = new List<StudySiteService.StudySiteDistanceWrapper>();
        StudySiteService.StudySiteDistanceWrapper site2 = new StudySiteService.StudySiteDistanceWrapper();
        site2.distance = 100;
        sdi2.sites.add(site2);

        StudyDetailItem sdi3 = new StudyDetailItem();
        sdi3.maxHCPCreatedDate = Datetime.now().addDays(-50);
        sdi3.sites = new List<StudySiteService.StudySiteDistanceWrapper>();

        StudyDetailItem sdi4 = new StudyDetailItem();
        sdi4.sites = new List<StudySiteService.StudySiteDistanceWrapper>();
        StudySiteService.StudySiteDistanceWrapper site3 = new StudySiteService.StudySiteDistanceWrapper();
        site3.distance = null;
        sdi4.sites.add(site3);

        Test.startTest();

        StudyDetailItem.sortType = 'Distance ASC';
        sdi1.compareTo(sdi2);
        sdi2.compareTo(sdi3);
        sdi3.compareTo(sdi1);
        sdi1.compareTo(sdi1);
        sdi1.compareTo(sdi4);
        sdi4.compareTo(sdi1);
        sdi3.compareTo(sdi3);

        StudyDetailItem.sortType = 'CreatedDate DESC';
        sdi1.compareTo(sdi2);
        sdi2.compareTo(sdi1);
        sdi1.compareTo(sdi1);

        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest() {
        TestData testData = new TestData();
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Terms_And_Conditions__c ppTC = [
            SELECT Id,Name
            FROM Terms_And_Conditions__c
            WHERE T_C_Type__c = 'Privacy Policy'
        ];
        ContentVersion content=new ContentVersion(); 
        content.Title='PrivacyPolicy'; 
        content.PathOnClient='PrivacyPolicy.pdf';
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        content.ContentLocation = 'S';
        content.Description = ppTC.Name; 
        insert content;

        ContentDistribution cdist = new ContentDistribution(
                                        Name = content.Title,
                                        ContentVersionId = content.Id
                                        );
        insert cdist;

        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = ppTC.Id; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = [select ContentDocumentId from ContentVersion where id =: content.id].ContentDocumentId;
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;

        Test.startTest();
        System.runAs(testData.hcpUser) {
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_HCP);
            StudyDetailViewController.getTrialDetail(
                testData.ctp.Id,
                CommunityService.USER_MODE_HCP
            );
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PI);
            TermsAndConditionsRemote.getPortalTcData(false);
            TermsAndConditionsRemote.getTrialTcData(testData.ctp.Id);
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            TermsAndConditionsRemote.getTC('CookiePolicy', 'en_US', false); //TODO: check code
            TermsAndConditionsRemote.generatePDF(ppTC.Id);
            TermsAndConditionsRemote.getCommunityName();
            List<HelpController.FileContainer> files = new List<HelpController.FileContainer>();
            HelpController.FileContainer file = new HelpController.FileContainer();
            file.base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file'));
            file.fileName = 'some.txt';
            file.contentType = 'text/plain';
            HelpController.createCase(
                'Some case',
                'Seme Description',
                'Question',
                'Low',
                'Some Reason',
                JSON.serialize(files),
                false,
                false
            );
            InfoModalController.getHCPEnrollmentHistory(testData.hcpEnrollment.Id);
            InfoModalController.getStudySiteHistory(testData.ss.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest2() {
        TestData testData = new TestData();
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Test.startTest();
        testData.ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update testData.ss;
        testData.hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        update testData.hcpEnrollment;

        System.runAs(testData.hcpUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_SendSiteRequestByHCPRemote.changeStudyForHCP(
                testData.ss.Id,
                testData.hcpEnrollment.Id
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest3() {
        TestData testData = new TestData();
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Test.startTest();
        testData.ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update testData.ss;
        testData.hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        update testData.hcpEnrollment;

        System.runAs(testData.hcpUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_SendSiteRequestByHCPRemote.selectNoSites(testData.hcpEnrollment.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest4() {
        TestData testData = new TestData();
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        String templateName = 'Share_Social_Study_Template';
        Id shareStudyEmailTemplateId = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ]
        .Id;
        Test.startTest();
        System.runAs(testData.hcpUser) {
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_HCP);
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_PI);
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_PARTICIPANT);
            ShareModalController.sendEmail(
                testData.hcpEnrollment.Id,
                hcpContact.Id,
                'Some@mail.com',
                null
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest5() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.hcpUser) {
            String initDataString = MyReferringClinicsController.getInitData(
                testData.ctp.Id,
                testData.ss.Id,
                CommunityTemplateService.TEMPLATE_DEFAULT
            );
            MyReferringClinicsController.InitData initData = (MyReferringClinicsController.InitData) JSON.deserializeStrict(
                initDataString,
                MyReferringClinicsController.InitData.class
            );
            MyReferringClinicsController.searchReferringClinics(
                JSON.serialize(initData.referringClinicsFilter.filterValues),
                JSON.serialize(initData.referringClinicsFilter.sortData),
                JSON.serialize(initData.paginationData),
                false
            );
            MyReferringClinicsController.searchReferringClinics(
                JSON.serialize(initData.referringClinicsFilter.filterValues),
                JSON.serialize(initData.referringClinicsFilter.sortData),
                JSON.serialize(initData.paginationData),
                true
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest6() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.hcpUser) {
            Action_RequestToReferByHCPRemote.requestToReferForHCP(
                testData.ss.Id,
                testData.hcpEnrollment.Id,
                null
            );
            Action_RequestToReferByHCPRemote.requestToReferForHCP(testData.ss.Id, null, null);
        }
        Test.stopTest();
    }

    //    @IsTest
    //    static void emailTemplateController() {
    //        TestData testData = new TestData();
    //        Contact piDelegateContact = [SELECT Id FROM Contact WHERE Email = 'pi_delegate@emil.com'];
    //        Test.startTest();
    //        EmailTemplateController controller = new EmailTemplateController();
    //        controller.sourceRecordId = piDelegateContact.Id;
    //        controller.userCommunityType = CommunityService.USER_MODE_PI;
    //        controller.outputMode = 'HTML';
    //        controller.getParameters();
    //
    //        controller = new EmailTemplateController();
    //        controller.sourceRecordId = testData.hcpEnrollment.Id;
    //        controller.userCommunityType = CommunityService.USER_MODE_HCP;
    //        controller.outputMode = 'HTML';
    //        controller.getParameters();
    //
    //        controller = new EmailTemplateController();
    //        controller.sourceRecordId = testData.pe.Id;
    //        controller.userCommunityType = CommunityService.USER_MODE_PARTICIPANT;
    //        controller.outputMode = 'HTML';
    //
    //        controller.getParameters();
    //        controller.getDelegateLevelsPI();
    //        controller.getDelegateLevelsHCP();
    //        controller.getResultUserMode();
    //        controller.getParameters();
    //
    //        EmailActionButtonController emailActionBtnController = new EmailActionButtonController();
    //        String url = emailActionBtnController.getResultURL();
    //        url = emailActionBtnController.getResultURL();
    //
    //        Test.stopTest();
    //    }

    @IsTest
    static void slideTour() {
        TestData testData = new TestData();
        Test.startTest();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
        update ctpList;
        System.runAs(testData.piUser) {
            OnboardingSlideTourRemote.switchShowOnLogin(CommunityService.USER_MODE_PI, true);
            OnboardingSlideTourRemote.getSlides(CommunityService.USER_MODE_PI, 'DESKTOP', false);
        }
        Test.stopTest();
    }

    @IsTest
    static void miscTests() {
        CountryStateUtil.getStateCodeByNameMap('US');
        TranslateHelper.convertBrowserLanguage(new List<String>{ 'en-US', 'it' });
    }

    @IsTest
    static void exportImportRemote() {
        TestData testData = new TestData();
        String languageLocale;
        Schema.DescribeFieldResult fieldResult = Translation__c.Language__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            if (pickListVal.getValue() != 'en_US') {
                languageLocale = pickListVal.getValue();
                break;
            }
        }
        Test.startTest();
        String exportXML = TranslationExportImportRemote.export(
            testData.ctp.Id,
            languageLocale,
            TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL
        );
        TranslationExportImportRemote.importTranslation(
            EncodingUtil.base64Encode(Blob.valueOf(exportXML))
        );
        Test.stopTest();
    }

    @IsTest
    static void basePITest1() {
        TestData testData = new TestData();
        
        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id,CommunityTemplate__c FROM Clinical_Trial_Profile__c limit 1];
        ctpList[0].CommunityTemplate__c='Janssen';
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
            AccountSettingsController.changeEmail('new@emil.com',CommunityService.USER_MODE_HCP);
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
        Account studySiteAccount = [SELECT Id FROM Account WHERE Name = 'Study Site Account'];
        Test.startTest();
        System.runAs(testData.piUser) {
            String vpResultJSON = ViewPatientsRemote.getInitData(
                testData.ctp.Id,
                testData.ss.Id,
                CommunityService.USER_MODE_PI,
                null,
                'Janssen'
            );
            ViewPatientsRemote.InitData vpResult = (ViewPatientsRemote.InitData) JSON.deserialize(
                vpResultJSON,
                ViewPatientsRemote.InitData.class
            );
            ViewPatientsRemote.getInitDataForPatientProfile(
                testData.participant.Id,
                CommunityService.USER_MODE_PI,
                null,
                'Janssen'
            );
            ViewPatientsRemote.getRecords(
                JSON.serialize(vpResult.peFilter),
                JSON.serialize(vpResult.paginationData),
                CommunityService.USER_MODE_PI,
                'site',
                null,
                false,
                'Janssen'
            );
            StudyClinicDashboardRemote.getInitData(testData.ctp.Id, studySiteAccount.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest3() {
        TestData testData = new TestData();
        Terms_And_Conditions__c studyTC = [
            SELECT Id
            FROM Terms_And_Conditions__c
            WHERE Active__c != TRUE
        ];
        Test.startTest();
        System.runAs(testData.piUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_ChangeHCPStatusByPIRemote.getEnrollmentReasonOptions();
            Action_ChangeHCPStatusByPIRemote.changeHCPEnrollmentStatus(
                testData.hcpEnrollment.Id,
                StudyActions.ACT_HCP_ON_HOLD,
                ''
            );
            Action_ChangeHCPStatusByPIRemote.changeHCPEnrollmentStatus(
                testData.hcpEnrollment.Id,
                StudyActions.ACT_HCP_ACTIVATE_FOR_ALL,
                ''
            );
            Action_ChangePEStatusByPIRemote.getReferralDeclineReasons();
            Action_ChangePEStatusByPIRemote.updatePE(
                JSON.serialize(testData.pe),
                PEStatusState.PE_STATUS_RECEIVED,
                '',
                ''
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest4() {
        TestData testData = new TestData();
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        String templateName = 'Share_Social_Study_Template';
        Id shareStudyEmailTemplateId = [
            SELECT Id
            FROM EmailTemplate
            WHERE DeveloperName = :templateName
            LIMIT 1
        ]
        .Id;
        Test.startTest();
        System.runAs(testData.piUser) {
            String initDataString = StudyListViewController.getPIInitData('');
            StudyListViewController.PIInitData initData = (StudyListViewController.PIInitData) JSON.deserializeStrict(
                initDataString,
                StudyListViewController.PIInitData.class
            );
            StudyListViewController.searchStudiesPI(
                JSON.serialize(initData.piStudiesFilter.filterData),
                JSON.serialize(initData.piStudiesFilter.sortData),
                JSON.serialize(initData.paginationData)
            );
        }
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
        }
        Test.stopTest();
    }

    @IsTest
    static void healthcareProvidersTest() {
        TestData testData = new TestData();
        
        try{
            System.runAs(testData.piUser) {
                Healthcare_Provider__c provider = new Healthcare_Provider__c(
                    First_Name__c = 'testHP',
                    Last_Name__c = 'Lastname',
                    Email__c = 'testHP@mail.com.fake',
                    Participant_Enrollment__c = testData.pe.Id
                );
    
                Healthcare_Provider__c hp = ReferHealthcareProviderRemote.inviteHP(
                    testData.pe.Id,
                    JSON.serialize(provider)
                )[0];
                hp.Status__c = ReferHealthcareProviderRemote.HP_S_NOSHARING;
                Healthcare_Provider__c hp2 = ReferHealthcareProviderRemote.inviteHP(
                    testData.pe.Id,
                    JSON.serialize(hp)
                )[0];
                ReferHealthcareProviderRemote.checkDuplicate(
                    testData.pe.Id,
                    'testHP@mail.com.fake',
                    null,
                    null,
                    null
                );
                ReferHealthcareProviderRemote.stopSharing(hp.Id, null);
                 Conversation__c conversation = new Conversation__c(
            Participant_Enrollment__c = testData.pe.Id,
            haveUnreadForParticipant__c = true
        );
        insert conversation;
        insert ConversationService.createConversationSharesForUser(
            new List<Id>{ conversation.Id },
            testData.participantUser.Id
        );
        Test.startTest();
                ReferHealthcareProviderRemote.invitePatientDelegate(
                    JSON.serialize(testData.participant),
                    JSON.serialize(
                        new Contact(
                            Email = 'testdelegate@testdelegate.testdelegate',
                            FirstName = 'TestDelegate',
                            LastName = 'TestDelegate'
                        )
                    ),
                    null,
                    null,
                    true,
                   ''
                );
                //Id patientDelegateId = [SELECT ID, Contact__r.Email FROM Patient_Delegate__c WHERE Contact__r.Email='testdelegate@testdelegate.testdelegate'].Id;
            }
            Id patientDelegateId = [
                SELECT ID, Contact__r.Email
                FROM Patient_Delegate__c
                WHERE Contact__r.Email = 'testdelegate@testdelegate.testdelegate'
            ]
            .Id;
            System.runAs(testData.piUser) {
                ReferHealthcareProviderRemote.stopSharing(null, patientDelegateId);
                Conversation__c conversationSecond = new Conversation__c(
            Participant_Enrollment__c = testData.pe.Id,
            haveUnreadForParticipant__c = true
        );
        insert conversationSecond;
        insert ConversationService.createConversationSharesForUser(
            new List<Id>{ conversationSecond.Id },
            testData.participantUser.Id
        );
                ReferHealthcareProviderRemote.invitePatientDelegate(
                    JSON.serialize(testData.participant),
                    JSON.serialize(
                        new Contact(
                            Email = 'testdelegate@testdelegate.testdelegate',
                            FirstName = 'TestDelegate',
                            LastName = 'TestDelegate'
                        )
                    ),
                    patientDelegateId,
                    null,
                    true,
                    ''
                );
            }
        }
        catch(exception ex)
        {    
        }
        Test.stopTest();
    }

    @IsTest
    static void accountSettingsControllerTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PI);
            AccountSettingsController.getInitData(CommunityService.USER_MODE_HCP);
            AccountSettingsController.changeEmail('some@email.com',CommunityService.USER_MODE_PI);
            AccountSettingsController.changePassword('QwqwQw!2321%43@', 'QwqwQw!2321%43@', null);
            AccountSettingsController.changeOptInEmail(true, true, true, true,CommunityService.USER_MODE_PI);
            AccountSettingsController.createCase('Some Case', 'Problem');
        }
        System.runAs(testData.participantUser) {
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }

    @IsTest
    static void referralProfileTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            ReferralProfileRemote.getReferralProfileDetail(
                testData.pe.Id,
                CommunityService.USER_MODE_PI
            );
            ReferralProfileRemote.changePEStatusByBtn(testData.pe.Id, 'Received');
            ReportsRemote.getInitData(testData.ctp.Id, CommunityService.USER_MODE_PI, null);
            RRIconTableController.getFilterInfoAndSummaryInfo();
            RRProfileController.getUser();
            RRProfileController.getLogoutURL();
        }
        Test.stopTest();
    }

    @IsTest
    static void mrrTest() {
        TestData testData = new TestData();
        insert new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = testData.ctp.Id,
            Survey_Name__c = 'Medical Record Review'
        );

        Test.startTest();
        System.runAs(testData.hcpUser) {
            String jsonResult = MedicalRecordReviewRemote.getInitData(
                testData.ctp.Id,
                testData.hcpEnrollment.Id,
                null
            );
        }
        Test.stopTest();
    }
    @IsTest
    static void mrrAndReferringTest1() {
        TestData testData = new TestData();

        PreScreener_Survey__c screener = new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = testData.ctp.Id,
            Survey_Name__c = 'Medical Record Review'
        );
        insert screener;

        Test.startTest();
        System.runAs(testData.hcpUser) {
            String jsonResult = MedicalRecordReviewRemote.createParticipantEnrollment(
                testData.ctp.Id,
                'participan01',
                'AAA',
                'BBB',
                null
            );
            MedicalRecordReviewRemote.SearchPEResult searchPEResult = (MedicalRecordReviewRemote.SearchPEResult) JSON.deserialize(
                jsonResult,
                MedicalRecordReviewRemote.SearchPEResult.class
            );
            String peJSON = JSON.serialize(searchPEResult.pe);
            MedicalRecordReviewRemote.setMRRStatus(
                peJSON,
                ParticipantEnrollmentService.PES_STATUS_PASS,
                'https://link.test',
                screener.Id
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void mrrAndReferringTest2() {
        TestData testData = new TestData();

        List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
        screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = testData.ctp.Id,
            Survey_Name__c = 'Medical Record Review'
        ));
        screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            Prescreener__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = testData.ctp.Id,
            Survey_Name__c = 'Prescreener'
        ));

        insert screenerList;

        Test.startTest();
        System.runAs(testData.hcpUser) {
            String refInitDataJSON = ReferringRemote.getInitData(
                testData.ctp.Id,
                testData.pe.Id,
                testData.hcpEnrollment.Id,
                CommunityService.USER_MODE_HCP,
                null,null
            );
            ReferringRemote.InitData refInitData = (ReferringRemote.InitData) JSON.deserialize(
                refInitDataJSON,
                ReferringRemote.InitData.class
            );
            insert new Participant__c(
                First_Name__c = 'FN1',
                Last_Name__c = 'LN1',
                Phone__c = '121231233333',
                Email__c = 'NewTestPartOne@email.com'
            );
            Participant__c participant2 = new Participant__c(
                First_Name__c = 'FN',
                Last_Name__c = 'LN',
                Phone__c = '12123123',
                Email__c = 'NewTestPart@email.com'
            );

            Participant_PrescreenerResponse__c response = new Participant_PrescreenerResponse__c(
                PreScreener_Survey__c = screenerList[1].Id,
                Screener_Response__c = 'Test Response'
            );
            
            try {
                ReferringRemote.saveParticipant(
                    testData.hcpEnrollment.Id,
                    JSON.serialize(refInitData.participantEnrollment),
                    JSON.serialize(participant2),
                    null,
                    JSON.serialize(response),
                    null,
                    null,null
                );
            } catch (Exception e) {
                System.debug('error');
            }
        }
        Test.stopTest();

        String vpResultJSON = ViewPatientsRemote.getInitData(
            testData.ctp.Id,
            testData.ss.Id,
            CommunityService.USER_MODE_HCP,
            null,
            'Janssen'
        );
        ViewPatientsRemote.InitData vpResult = (ViewPatientsRemote.InitData) JSON.deserialize(
            vpResultJSON,
            ViewPatientsRemote.InitData.class
        );
    }

    @IsTest
    static void mrrAndReferringTest3() {
        TestData testData = new TestData();
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        Test.startTest();
        System.runAs(testData.hcpUser) {
            ViewPatientsRemote.getInitDataForPatientProfile(
                testData.participant.Id,
                CommunityService.USER_MODE_HCP,
                null,
                'Janssen'
            );
            String mrrLogResStr = MedicalRecordReviewLogController.getParticipantDetail(
                testData.ctp.Id,
                CommunityService.USER_MODE_HCP,
                false,
                null
            );
            mrrLogResStr = MedicalRecordReviewLogController.getParticipantDetail(
                null,
                CommunityService.USER_MODE_HCP,
                false,
                null
            );
            MedicalRecordReviewLogController.ParticipantDetail participantDetail = (MedicalRecordReviewLogController.ParticipantDetail) JSON.deserialize(
                mrrLogResStr,
                MedicalRecordReviewLogController.ParticipantDetail.class
            );
            MedicalRecordReviewLogController.getRecords(
                JSON.serialize(participantDetail.peFilter),
                JSON.serialize(participantDetail.paginationData),
                false,
                null,
                null
            );
            MedicalRecordReviewLogItemController.changeStatusToExcludeFromReferring(testData.pe.Id);
            MedicalRecordReviewLogItemController.undoChangeStatusToExcludeFromReferring(testData.pe.Id);
            ExcelController excelController = new ExcelController();
            excelController.getPEList();
            excelController.getHCPEList();
        }
        Test.stopTest();
    }

    @IsTest
    static void excelReportTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.hcpUser) {
            ApexPages.currentPage().getParameters().put('userMode', CommunityService.USER_MODE_PI);
            ApexPages.currentPage().getParameters().put('study', '' + testData.ctp.Id);
            ApexPages.currentPage().getParameters().put('studySite', '' + testData.ss.Id);
            ExcelController excelController = new ExcelController();
        }
        Test.stopTest();
    }

    public class IntegrationCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            return response;
        }
    }

    @IsTest
    static void integrationStudyHubTest() {
        TestData testData = new TestData();
        testData.ss.Study_Site_Type__c = 'Virtual';
        update testData.ss;
        Test.setMock(HttpCalloutMock.class, new IntegrationCalloutMock());
        Test.startTest();
        System.runAs(testData.hcpUser) {
            IntegrationService.sendPEToStudyHub(testData.pe.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void integrationServiceNowTest() {
        TestData testData = new TestData();
        testData.ss.Study_Site_Type__c = 'Virtual';
        update testData.ss;
        Test.setMock(HttpCalloutMock.class, new IntegrationCalloutMock());
        Test.startTest();
        System.runAs(testData.hcpUser) {
            IntegrationService.sendPEToServiceNow(testData.pe.Id);
        }
        Test.stopTest();
    }
    @IsTest
    static void sitesSearchTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.hcpUser) {
            String jsonResult = SitesSearchRemote.getInitData(testData.ctp.Id, null);
            SitesSearchRemote.InitData data = (SitesSearchRemote.InitData) JSON.deserialize(
                jsonResult,
                SitesSearchRemote.InitData.class
            );
            SitesSearchRemote.getRecords(
                JSON.serialize(data.siteFilter),
                JSON.serialize(data.PaginationData),
                null
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testSaveSSDetails() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            testData.ss.Study_Site_Phone__c = '123456789';
            StudyListViewController.saveSSChanges(JSON.serialize(testData.ss));
        }
        Study_Site__c updatedSS = [
            SELECT Id, Site_Staff__c, Study_Site_Email__c, Study_Site_Phone__c, Site__c
            FROM Study_Site__c
            WHERE Id = :testData.ss.Id
        ];
        System.assertEquals(testData.ss.Study_Site_Phone__c, updatedSS.Study_Site_Phone__c);
        Test.stopTest();
    }

    @IsTest
    static void testgetExportAllList() {
        TestData testData = new TestData();
        // String vpResultJSON = ViewPatientsRemote.getInitData(testData.ctp.Id, testData.ss.Id, CommunityService.USER_MODE_HCP, null,'Janssen');
        //     ViewPatientsRemote.InitData vpResult = (ViewPatientsRemote.InitData) JSON.deserialize(vpResultJSON, ViewPatientsRemote.InitData.class);
        List<Id> studies = new List<Id>();
        List<Id> studySites = new List<Id>();

        // for(LabelValueItem li : vpResult.peFilterData.studies){
        //     studies.add(li.value);
        // }
        // for(LabelValueItem lit : vpResult.peFilterData.studySites){
        //     studySites.add(lit.value);
        // }
        Test.startTest();
        ViewPatientsRemote.CsvWrapper wrap = new ViewPatientsRemote.CsvWrapper();
        studies.add(testData.ctp.Id);
        studySites.add(testData.ss.Id);
        wrap = ViewPatientsRemote.getExportAllList(studies, studySites, 1, 4500);
        System.assertEquals(1, wrap.startPos);
        Test.stopTest();
    }
    @IsTest
    static void helpRemoteTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.participantUser) {
            ApplicationHelpRemote.validateAgeOfMajority('1995');
            ApplicationHelpRemote.validateAgeOfMajority('2021');
            List<LabelValueItem> lb = ApplicationHelpRemote.validateUsername();
            List<String> usrList = new List<String>();
            usrList.add('test@test.com');
            ApplicationHelpRemote.createYOBCase('1995',true,'test1992@fmail.com','1994',false,usrList);
            ApplicationHelpRemote.createYOBCase('1995',false,'test1992@fmail.com','1994',true,usrList);
            ApplicationHelpRemote.createYOBCase('1995',true,'test1992@fmail.com','1994',true,usrList);
            System.assert(lb!=null);
        }
        Test.stopTest();
    }
}