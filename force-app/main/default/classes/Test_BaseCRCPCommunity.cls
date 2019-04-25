/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_BaseCRCPCommunity {

    static Account piAccount;
    static Account hcpAccount;
    static Account studySiteAccount;
    static Account participantsAccount;
    static Account delegateAccount;

    static Contact piContact;
    static Contact hcpContact;
    static Contact piDelegateContact;
    static Contact hcpDelegateContact;


    static User piUser;
    static User hcpUser;

    static Clinical_Trial_Profile__c study;
    static Translation__c studyTranslation;
    static Study_Site__c studySite;
    static HCP_Enrollment__c hcpEnrollment;
    static Site_Staff__c siteStaff;
    static Referring_HCP_Staff__c referringHcpStaff;

    static Terms_And_Conditions__c portalTC;
    static Terms_And_Conditions__c studyTC;

    static Participant_Enrollment__c mrrPE;
    static Participant_Enrollment__c passedMrrPE;
    static User participantUser;
    static Therapeutic_Area__c area;

    static Participant__c participant;
    static Referral_Network__c referralNetwork;
    static Contact_Referral_Network__c contactReferralNetwork;
    static Contact_Therapeutic_Area__c contactTherapeuticArea;


    static void init() {

        portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );
        insert portalTC;

        studyTC = new Terms_And_Conditions__c();
        insert studyTC;

        participantsAccount = new Account(
                Name = 'Participant'
        );
        insert participantsAccount;

        piAccount = new Account(
                Name = 'PI Account'
        );
        insert piAccount;

        hcpAccount = new Account(
                Name = 'HCP Account'
        );
        insert hcpAccount;

        delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        insert delegateAccount;

        studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509
        );
        insert studySiteAccount;

        piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id
        );
        insert piContact;

        piDelegateContact = new Contact(
                FirstName = 'PI_Delegate',
                LastName = 'PI_Delegate',
                Email = 'pi_delegate@emil.com',
                AccountId = piAccount.Id,
                userCommunityMode__c = 'PI'
        );
        insert piDelegateContact;

        hcpContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509
        );
        insert hcpContact;

        hcpDelegateContact = new Contact(
                FirstName = 'HCP_Delegate',
                LastName = 'HCP_Delegate',
                Email = 'hcp_delegate@emil.com',
                AccountId = hcpAccount.Id
        );
        insert hcpDelegateContact;
        area = new Therapeutic_Area__c(Name = 'Test TA');
        insert area;
        study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456789',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000001',
                Link_to_Pre_screening__c = 'some link',
                Terms_And_Conditions_ID__c = studyTC.Id,
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Therapeutic_Area__c = area.Id,
                Participating_in_Digital_Recruitment__c = 'YES',
                Participating_in_Rocket_Referral__c = 'YES'
        );
        insert study;

        studyTranslation = new Translation__c(
                Language__c = 'ru',
                Record_Id__c = study.Id,
                Field_Name__c = 'Study_Title__c',
                Value__c = 'Some translated value'
        );
        insert studyTranslation;

        studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Is_Virtual_Study_Site__c = false,
                Suppress_Participant_Emails__c = false
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;

        hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = studySite.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollment;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment;

        siteStaff = new Site_Staff__c(
                Site_Contact__c = piDelegateContact.Id,
                Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
                Study_Site__c = studySite.Id
        );
        insert siteStaff;

        referringHcpStaff = new Referring_HCP_Staff__c(
                Contact__c = hcpDelegateContact.Id,
                Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
                HCP_Enrollment__c = hcpEnrollment.Id
        );
        insert referringHcpStaff;

        mrrPE = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PENDING,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatienntId',
                Referral_Source__c = 'HCP'
        );
        insert mrrPE;

        participant = new Participant__c(
                First_Name__c = 'Part1',
                Last_Name__c = 'Part1',
                Phone__c = '55313535',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL'
        );
        insert participant;
        participant = [SELECT Id, Name FROM Participant__c WHERE Id = :participant.Id];
        passedMrrPE = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatienntId2',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_REFERRAL_SENT_TO_PI,
                Participant__c = participant.Id
        );
        insert passedMrrPE;
        participantUser = [SELECT Id FROM User WHERE Contact.LastName = :participant.Name];

        referralNetwork = new Referral_Network__c(
                Name = 'Test Referral Network'
        );
        insert referralNetwork;

        contactReferralNetwork = new Contact_Referral_Network__c(
                ContactId__c = hcpContact.Id,
                ReferralNetworkId__c = referralNetwork.Id
        );
        insert contactReferralNetwork;

        contactTherapeuticArea = new Contact_Therapeutic_Area__c(
                ContactId__c = hcpContact.Id,
                TherapeuticAreaId__c = area.Id
        );
        insert contactTherapeuticArea;

        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];

        Terms_And_Conditions_Acceptance__c tc_acceptance = new Terms_And_Conditions_Acceptance__c(
                User__c = hcpUser.Id,
                Terms_And_Conditions__c = studyTC.Id
        );
        insert tc_acceptance;
    }

    @IsTest
    static void testReferralNetworkService_AutoEmails() {
        init();
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
                Is_Virtual_Study_Site__c = false,
                Suppress_Participant_Emails__c = false,
                ReferralNetworkId__c = referralNetwork.Id
        );
        insert studySite;
        Test.stopTest();
    }

    @IsTest
    static void testReferralNetworkService_Subscription() {
        init();

        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> recordsRN = SubscribeToReferralNetworkRemote.getReferralNetworkRecords('Referral_Network__c');
            SubscribeToReferralNetworkRemote.searchForReferralNetworks(recordsRN[0].Name, 'Referral_Network__c');
            SubscribeToReferralNetworkRemote.deleteRecords(new List<Id>{
                    recordsRN[0].Id
            });

            SubscribeToReferralNetworkRemote.ReferralNetworkWrapper newRecordRN = new SubscribeToReferralNetworkRemote.ReferralNetworkWrapper();
            newRecordRN.Id = recordsRN[0].Id;
            newRecordRN.isSelected = true;
            SubscribeToReferralNetworkRemote.saveReferralNetworks(JSON.serialize(newRecordRN));

            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> recordsTA = SubscribeToReferralNetworkRemote.getReferralNetworkRecords('Therapeutic_Area__c');
            SubscribeToReferralNetworkRemote.searchForReferralNetworks(recordsTA[0].Name, 'Therapeutic_Area__c');
            SubscribeToReferralNetworkRemote.deleteRecords(new List<Id>{
                    recordsTA[0].Id
            });

            SubscribeToReferralNetworkRemote.ReferralNetworkWrapper newRecordTA = new SubscribeToReferralNetworkRemote.ReferralNetworkWrapper();
            newRecordTA.Id = recordsTA[0].Id;
            newRecordTA.isSelected = true;
            SubscribeToReferralNetworkRemote.saveReferralNetworks(JSON.serialize(newRecordTA));
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPAdvancedTest() {
        init();
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            String stringData = StudyListViewController.getHCPInitData();
            StudyListViewController.HCPInitData initData = (StudyListViewController.HCPInitData) JSON.deserializeStrict(stringData, StudyListViewController.HCPInitData.class);

            StudyListViewController.searchStudies(JSON.serialize(initData.filterData), JSON.serialize(initData.sortData), JSON.serialize(initData.paginationData), false);
            StudyListViewController.searchStudies(JSON.serialize(initData.filterData), JSON.serialize(initData.sortData), JSON.serialize(initData.paginationData), true);
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
        init();
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_HCP);
            StudyDetailViewController.getTrialDetail(study.Id, CommunityService.USER_MODE_HCP);
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI);
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PI);
            TermsAndConditionsRemote.getPortalTcData();
            TermsAndConditionsRemote.getTrialTcData(study.Id);
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            TermsAndConditionsRemote.getTC(studyTC.Id, 'en_US');//TODO: check code
            List<HelpController.FileContainer> files = new List<HelpController.FileContainer>();
            HelpController.FileContainer file = new HelpController.FileContainer();
            file.base64Data = EncodingUtil.base64Encode(Blob.valueOf('Test file'));
            file.fileName = 'some.txt';
            file.contentType = 'text/plain';
            HelpController.createCase('Some case', 'Question', JSON.serialize(files));
            InfoModalController.getHCPEnrollmentHistory(hcpEnrollment.Id);
            InfoModalController.getStudySiteHistory(studySite.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest2() {
        init();
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        update hcpEnrollment;
        Test.startTest();
        System.runAs(hcpUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_SendSiteRequestByHCPRemote.changeStudyForHCP(studySite.Id, hcpEnrollment.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest3() {
        init();
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        update hcpEnrollment;
        Test.startTest();
        System.runAs(hcpUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_SendSiteRequestByHCPRemote.selectNoSites(hcpEnrollment.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest4() {
        init();
        Test.startTest();
        System.runAs(hcpUser) {
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_HCP);
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_PI);
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_PARTICIPANT);
            ShareModalController.sendEmail(hcpEnrollment.Id, hcpContact.Id, 'Some@mail.com', 'SOCIAL_SHARING');
            ShareModalController.sendEmail(hcpEnrollment.Id, hcpContact.Id, 'Some@mail.com', null);
        }
        Test.stopTest();
    }

    @IsTest
    static void emailTemplateController() {
        init();
        Test.startTest();
        EmailTemplateController controller = new EmailTemplateController();
        controller.sourceRecordId = piDelegateContact.Id;
        controller.userCommunityType = CommunityService.USER_MODE_PI;
        controller.outputMode = 'HTML';
        controller.getParameters();

        controller = new EmailTemplateController();
        controller.sourceRecordId = hcpEnrollment.Id;
        controller.userCommunityType = CommunityService.USER_MODE_HCP;
        controller.outputMode = 'HTML';
        controller.getParameters();

        controller = new EmailTemplateController();
        controller.sourceRecordId = passedMrrPE.Id;
        controller.userCommunityType = CommunityService.USER_MODE_PARTICIPANT;
        controller.outputMode = 'HTML';

        controller.getParameters();
        controller.getDelegateLevelsPI();
        controller.getDelegateLevelsHCP();
        controller.getResultUserMode();
        controller.getParameters();
        Test.stopTest();
    }

    @IsTest
    static void slideTour() {
        init();
        Test.startTest();
        System.runAs(piUser) {
            /*String initDataStr = OnboardingSlideTourRemote.getInitData();
            OnboardingSlideTourRemote.InitData initData =
                    (OnboardingSlideTourRemote.InitData)JSON.deserialize(
                            initDataStr, OnboardingSlideTourRemote.InitData.class
                    );*/
            OnboardingSlideTourRemote.switchShowOnLogin(CommunityService.USER_MODE_PI, true);
            OnboardingSlideTourRemote.getSlides(CommunityService.USER_MODE_PI, 'DESKTOP', false);
        }
        Test.stopTest();
    }


    @IsTest
    static void miscTests() {
        init();
        CountryStateUtil.getStateCodeByNameMap('US');
        TranslateHelper.convertBrowserLanguage(new List<String>{
                'en-US', 'it'
        });

    }


    @IsTest
    static void exportImportRemote() {
        init();
        String exportXML = TranslationExportImportRemote.export(study.Id, 'ru', TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
        TranslationExportImportRemote.importTranslation(EncodingUtil.base64Encode(Blob.valueOf(exportXML)));
    }

    @IsTest
    static void batchUpdateRecordsTest() {
        init();
        Test.startTest();
        Batch_UpdateRecords.run();
        Test.stopTest();
    }

    @IsTest
    static void myStudySiteDetail() {
        init();
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            MyStudySitesController.getStudySiteDetail(study.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void hcpDelegateTest() {
        init();
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];

        System.runAs(hcpUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_HCP);
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_HCP, 'hcp_delegate@emil.com'), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]));
            detail.delegates[0].trialLevels[0].delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]));
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_HCP, 'hcp_delegate_new@emil.com'), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New HCP Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New HCP Delegate';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]));
        }
        Test.stopTest();
    }

    @IsTest
    static void piDelegateTest() {
        init();
        Test.startTest();

        System.runAs(piUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PI);
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_PI, 'pi_delegate@emil.com'), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]));
            detail.delegates[0].trialLevels[0].delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]));
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_PI, 'pi_delegate_new@emil.com'), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New PI Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New PI Delegate';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]));
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest1() {
        init();
        Test.startTest();
        piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        System.runAs(piUser) {
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_PI);
            StudyDetailViewController.getTrialDetail(study.Id, CommunityService.USER_MODE_PI);
            StudyDetailAboutStudyRemote.setTrialAcceptedForPI(study.Id, null);
            DashboardRemote.getInitData(CommunityService.USER_MODE_HCP);
            AccountSettingsController.getInitData(CommunityService.USER_MODE_HCP);
            AccountSettingsController.changeEmail('new@emil.com');
            AccountSettingsController.changePassword('Dd231324d13', 'Dd231324d13', '11111');
            ClinicProfileRemote.getClinicProfileData(hcpAccount.Id);
            CommunityFacadeRemote.getCommunityData();
            CommunityFacadeRemote.changeMode(CommunityService.USER_MODE_PI);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest2() {
        init();
        Test.startTest();
        piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        System.runAs(piUser) {
            String vpResultJSON = ViewPatientsRemote.getInitData(study.Id, studySite.Id, CommunityService.USER_MODE_PI, null, CommunityService.USER_MODE_PI);
            ViewPatientsRemote.InitData vpResult = (ViewPatientsRemote.InitData) JSON.deserialize(vpResultJSON, ViewPatientsRemote.InitData.class);
            ViewPatientsRemote.getStatistics(CommunityService.USER_MODE_PI);
            ViewPatientsRemote.getInitDataForPatientProfile(participant.Id, CommunityService.USER_MODE_PI);
            ViewPatientsRemote.getStatistics(CommunityService.USER_MODE_PI);
            ViewPatientsRemote.getRecords(JSON.serialize(vpResult.peFilter), JSON.serialize(vpResult.paginationData), 'Pending', CommunityService.USER_MODE_PI, false);
            StudyClinicDashboardRemote.getInitData(study.Id, studySiteAccount.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest3() {
        init();
        Test.startTest();
        piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        System.runAs(piUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_ChangeHCPStatusByPIRemote.getEnrollmentReasonOptions();
            Action_ChangeHCPStatusByPIRemote.changeHCPEnrollmentStatus(hcpEnrollment.Id, StudyActions.ACT_HCP_ON_HOLD, '');
            Action_ChangePEStatusByPIRemote.getReferralDeclineReasons();
            Action_ChangePEStatusByPIRemote.updatePE(passedMrrPE.Id, PEStatusState.PE_STATUS_REFERRAL_ON_HOLD, '', '');
        }
        Test.stopTest();
    }

    @IsTest
    static void accountSettingsControllerTest() {
        init();
        Test.startTest();
        piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        System.runAs(piUser) {
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PI);
            AccountSettingsController.getInitData(CommunityService.USER_MODE_HCP);
            AccountSettingsController.changeEmail('some@email.com');
            AccountSettingsController.changePassword('QwqwQw!2321%43@', 'QwqwQw!2321%43@', null);
            AccountSettingsController.changeOptInEmail(true, true, true, true);
            AccountSettingsController.createCase('Some Case', 'Problem');
        }
        System.runAs(participantUser) {
            AccountSettingsController.getInitData(CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }

    @IsTest
    static void myReferringClinics() {
        init();
        Test.startTest();
        piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        System.runAs(piUser) {
            MyReferredZoneController.getStatusOptions(CommunityService.USER_MODE_PI);
            MyReferringClinicsController.getClinicDetail(study.Id, CommunityService.USER_MODE_PI);
            MyReferringClinicsController.getEnrollmentData(hcpEnrollment.Id, CommunityService.USER_MODE_PI);

        }
        Test.stopTest();
    }

    @IsTest
    static void referralProfileTest() {
        init();
        Test.startTest();
        piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        System.runAs(piUser) {
            ReferralProfileRemote.getReferralProfileDetail(passedMrrPE.Id, CommunityService.USER_MODE_PI);
            ReferralProfileRemote.getPEStatusHistory(passedMrrPE.Id, CommunityService.USER_MODE_PI);
            ReferralProfileRemote.changePEStatusByBtn(passedMrrPE.Id, 'Referral Accepted');
            ReferralProfileRemote.changePEStatus(passedMrrPE.Id, 'Contact Successful', 'Some Notes', CommunityService.USER_MODE_PI);
            ReportsRemote.getInitData(study.Id, CommunityService.USER_MODE_PI);
            RRIconTableController.getFilterInfoAndSummaryInfo();
            RRProfileController.getUser();
            RRProfileController.getLogoutURL();
            //ShareModalController.sendEmail(study.Id, 'someemail@mail.com');
        }
        Test.stopTest();
    }

    @IsTest
    static void mrrAndReferringTest() {
        init();
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            //MedicalRecordReviewRemote.getHCPEnrolment(study.Id);
            String jsonResult = MedicalRecordReviewRemote.createParticipantEnrollment(study.Id, 'participan01', 'AAA', 'BBB');
            MedicalRecordReviewRemote.SearchPEResult searchPEResult = (MedicalRecordReviewRemote.SearchPEResult) JSON.deserialize(jsonResult, MedicalRecordReviewRemote.SearchPEResult.class);
            String peJSON = JSON.serialize(searchPEResult.pe);
            MedicalRecordReviewRemote.setMRRStatus(peJSON, ParticipantEnrollmentService.PES_STATUS_PASS);
            Participant_Enrollment__c pe = [SELECT Id FROM Participant_Enrollment__c LIMIT 1];
            String refInitDataJSON = ReferringRemote.getInitData(study.Id, pe.Id, hcpEnrollment.Id, CommunityService.USER_MODE_HCP);
            ReferringRemote.InitData refInitData = (ReferringRemote.InitData) JSON.deserialize(refInitDataJSON, ReferringRemote.InitData.class);
            Participant__c participant2 = new Participant__c(
                    First_Name__c = 'FN',
                    Last_Name__c = 'LN',
                    Phone__c = '12123123',
                    Email__c = 'NewTestPart@email.com'
            );
            ReferringRemote.saveParticipant(null, hcpEnrollment.Id, JSON.serialize(refInitData.participantEnrollment), JSON.serialize(participant2));
            participant2 = [SELECT Id, Contact__c FROM Participant__c WHERE First_Name__c = 'FN' AND Last_Name__c = 'LN' LIMIT 1];
            String vpResultJSON = ViewPatientsRemote.getInitData(study.Id, studySite.Id, CommunityService.USER_MODE_HCP, null, CommunityService.USER_MODE_HCP);
            ViewPatientsRemote.InitData vpResult = (ViewPatientsRemote.InitData) JSON.deserialize(vpResultJSON, ViewPatientsRemote.InitData.class);

            ViewPatientsRemote.getStatistics(CommunityService.USER_MODE_HCP);
            ViewPatientsRemote.getInitDataForPatientProfile(participant2.Id, CommunityService.USER_MODE_HCP);
            String mrrLogResStr = MedicalRecordReviewLogController.getParticipantDetail(study.Id, CommunityService.USER_MODE_HCP, false);
            mrrLogResStr = MedicalRecordReviewLogController.getParticipantDetail(null, CommunityService.USER_MODE_HCP, false);
            MedicalRecordReviewLogController.ParticipantDetail participantDetail = (MedicalRecordReviewLogController.ParticipantDetail) JSON.deserialize(mrrLogResStr, MedicalRecordReviewLogController.ParticipantDetail.class);
            MedicalRecordReviewLogController.getRecords(JSON.serialize(participantDetail.peFilter), JSON.serialize(participantDetail.paginationData), false);
            MedicalRecordReviewLogItemController.changeStatusToExcludeFromReferring(mrrPE.Id);
            ExcelController excelController = new ExcelController();
            excelController.getPEList();
            excelController.getHCPEList();
        }
        Test.stopTest();
    }

    @IsTest
    static void excelReportTest() {
        init();
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            ApexPages.currentPage().getParameters().put('userMode', CommunityService.USER_MODE_PI);
            ApexPages.currentPage().getParameters().put('study', '' + study.Id);
            ApexPages.currentPage().getParameters().put('studySite', '' + studySite.Id);
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
        init();
        studySite.Is_Virtual_Study_Site__c = true;
        update studySite;
        Test.setMock(HttpCalloutMock.class, new IntegrationCalloutMock());
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            IntegrationService.sendPEToStudyHub(passedMrrPE.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void integrationServiceNowTest() {
        init();
        studySite.Is_Virtual_Study_Site__c = true;
        update studySite;
        Test.setMock(HttpCalloutMock.class, new IntegrationCalloutMock());
        Test.startTest();
        hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        System.runAs(hcpUser) {
            IntegrationService.sendPEToServiceNow(passedMrrPE.Id);
        }
        Test.stopTest();
    }
}