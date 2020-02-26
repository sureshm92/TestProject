/**
 * Created by Leonid Bartenev
 */

@IsTest(IsParallel=false)
private class Test_BaseCRCPCommunity {

    @TestSetup
    static void init() {
        Test.startTest();
        List<Terms_And_Conditions__c> termsAndConditions = new List<Terms_And_Conditions__c>();
        Terms_And_Conditions__c portalTC = new Terms_And_Conditions__c(
                Active__c = true
        );
        termsAndConditions.add(portalTC);
        
        Terms_And_Conditions__c studyTC = new Terms_And_Conditions__c();
        termsAndConditions.add(studyTC);
        insert termsAndConditions;
        
        List<Account> accounts = new List<Account>();
        Account participantsAccount = new Account(
                Name = 'Participant'
        );
        accounts.add(participantsAccount);
        
        Account piAccount = new Account(
                Name = 'PI Account'
        );
        accounts.add(piAccount);
        
        Account hcpAccount = new Account(
                Name = 'HCP Account'
        );
        accounts.add(hcpAccount);
        
        Account delegateAccount = new Account(
                Name = CommunityService.COMMUNITY_DELEGATE_ACCOUNT_NAME
        );
        accounts.add(delegateAccount);
        
        Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509
        );
        accounts.add(studySiteAccount);
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        Contact piContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'pi@emil.com',
                AccountId = piAccount.Id,
                Language__c = 'en_US'
        );
        contacts.add(piContact);
        
        Contact piDelegateContact = new Contact(
                FirstName = 'PI_Delegate',
                LastName = 'PI_Delegate',
                Email = 'pi_delegate@emil.com',
                AccountId = piAccount.Id,
                userCommunityMode__c = 'PI'
        );
        contacts.add(piDelegateContact);
        
        Contact hcpContact = new Contact(
                FirstName = 'PI',
                LastName = 'PI',
                Email = 'hcp@emil.com',
                AccountId = hcpAccount.Id,
                MailingLatitude = 40.766594,
                MailingLongitude = -73.991509,
                Language__c = 'en_US'
        );
        contacts.add(hcpContact);
        
        Contact  hcpDelegateContact = new Contact(
                FirstName = 'HCP_Delegate',
                LastName = 'HCP_Delegate',
                Email = 'hcp_delegate@emil.com',
                AccountId = hcpAccount.Id
        );
        contacts.add(hcpDelegateContact);
        insert contacts;
        
        Therapeutic_Area__c area = new Therapeutic_Area__c(Name = 'Test TA');
        insert area;
        
        Visit_Plan__c vp = new Visit_Plan__c();
        insert vp;
        
        Clinical_Trial_Profile__c study = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456789',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000001',
                Link_to_Pre_screening__c = 'some link',
                Terms_And_Conditions_ID__c = studyTC.Id,
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false,
                Therapeutic_Area__c = area.Id,
                Synch_with_TMDH__c = true,
                Include_in_RP_trial_search__c = true,
                Visit_Plan__c = vp.Id
        );
        insert study;
        
        String languageLocale;
        Schema.DescribeFieldResult fieldResult = Translation__c.Language__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getValue()!='en_US'){
                languageLocale =pickListVal.getValue();
                break;
            }
        }
        
        Translation__c  studyTranslation = new Translation__c(
                Language__c = languageLocale,
                Record_Id__c = study.Id,
                Field_Name__c = 'Study_Title__c',
                Value__c = 'Some translated value'
        );
        insert studyTranslation;
        
        Study_Site__c  studySite = new Study_Site__c(
                Principal_Investigator__c = piContact.Id,
                Clinical_Trial_Profile__c = study.Id,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Site__c = studySiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
        );
        insert studySite;
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;
        
        HCP_Enrollment__c hcpEnrollment = new HCP_Enrollment__c(
                Study_Site__c = studySite.Id,
                HCP_Contact__c = hcpContact.Id,
                Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT
        );
        insert hcpEnrollment;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_ACTIVATED;
        update hcpEnrollment;
        
        Site_Staff__c  siteStaff = new Site_Staff__c(
                Site_Contact__c = piDelegateContact.Id,
                Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
                Study_Site__c = studySite.Id
        );
        insert siteStaff;
        
        Referring_HCP_Staff__c   referringHcpStaff = new Referring_HCP_Staff__c(
                Contact__c = hcpDelegateContact.Id,
                Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
                HCP_Enrollment__c = hcpEnrollment.Id
        );
        insert referringHcpStaff;
        
        Participant__c   participant = new Participant__c(
                First_Name__c = 'Part1',
                Last_Name__c = 'Part1',
                Phone__c = '55313535',
                Email__c = 'part1@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Preferred_Language__c = 'en_US',
                Adult__c = true
        );
        insert participant;
        
        List<Participant_Enrollment__c> participantEnrollments = new List<Participant_Enrollment__c>();
        Participant_Enrollment__c   mrrPE = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PENDING,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatienntId',
                Referral_Source__c = 'HCP'
        );
        participantEnrollments.add(mrrPE);
        
        Participant_Enrollment__c   passedMrrPE = new Participant_Enrollment__c(
                HCP__c = hcpEnrollment.Id,
                HCP_Contact_HCPEnroll__c = hcpContact.Id,
                Pre_screening_Status__c = ParticipantEnrollmentService.PES_STATUS_NOT_REQUIRED,
                Medical_Record_Review_Status__c = ParticipantEnrollmentService.MRR_STATUS_PASS,
                PI_Contact__c = piContact.Id,
                Study_Site__c = studySite.Id,
                Patient_ID__c = 'SomePatienntId2',
                Referral_Source__c = 'HCP',
                Participant_Status__c = ParticipantEnrollmentService.PART_STATUS_RECEIVED,
                Participant__c = participant.Id
        );
        participantEnrollments.add(passedMrrPE);
        insert participantEnrollments;
        
        Referral_Network__c   referralNetwork = new Referral_Network__c(
                Name = 'Test Referral Network'
        );
        insert referralNetwork;
        
        Contact_Referral_Network__c   contactReferralNetwork = new Contact_Referral_Network__c(
                ContactId__c = hcpContact.Id,
                ReferralNetworkId__c = referralNetwork.Id
        );
        insert contactReferralNetwork;
        
        Contact_Therapeutic_Area__c   contactTherapeuticArea = new Contact_Therapeutic_Area__c(
                ContactId__c = hcpContact.Id,
                TherapeuticAreaId__c = area.Id
        );
        insert contactTherapeuticArea;
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        
        Terms_And_Conditions_Acceptance__c tc_acceptance = new Terms_And_Conditions_Acceptance__c(
                User__c = hcpUser.Id,
                Terms_And_Conditions__c = studyTC.Id
        );
        insert tc_acceptance;
        Test.stopTest();
    }
    
    @IsTest
    static void testReferralNetworkService_AutoEmails() {
        Terms_And_Conditions__c studyTC = [SELECT Id FROM Terms_And_Conditions__c WHERE Active__c != TRUE];
        Therapeutic_Area__c area = [SELECT Id FROM Therapeutic_Area__c WHERE Name = 'Test TA'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        Account studySiteAccount = [SELECT Id FROM Account WHERE Name = 'Study Site Account'];
        Referral_Network__c referralNetwork = [SELECT Id FROM Referral_Network__c WHERE Name = 'Test Referral Network'];
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
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> recordsRN = SubscribeToReferralNetworkRemote.getReferralNetworkRecords('Referral_Network__c');
            SubscribeToReferralNetworkRemote.searchForReferralNetworks(recordsRN[0].Name, 'Referral_Network__c');
            SubscribeToReferralNetworkRemote.deleteAndGetRefferalNetworks('Referral_Network__c', new List<Id>{
                    recordsRN[0].Id
            });
            
            SubscribeToReferralNetworkRemote.ReferralNetworkWrapper newRecordRN = new SubscribeToReferralNetworkRemote.ReferralNetworkWrapper();
            newRecordRN.Id = recordsRN[0].Id;
            newRecordRN.isSelected = true;
            SubscribeToReferralNetworkRemote.saveReferralNetworks(JSON.serialize(newRecordRN));
            
            List<SubscribeToReferralNetworkRemote.ReferralNetworkWrapper> recordsTA = SubscribeToReferralNetworkRemote.getReferralNetworkRecords('Therapeutic_Area__c');
            SubscribeToReferralNetworkRemote.searchForReferralNetworks(recordsTA[0].Name, 'Therapeutic_Area__c');
            SubscribeToReferralNetworkRemote.deleteAndGetRefferalNetworks('Referral_Network__c', new List<Id>{
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
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            String stringData = StudyListViewController.getHCPInitData(null);
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
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Terms_And_Conditions__c studyTC = [SELECT Id FROM Terms_And_Conditions__c WHERE Active__c != TRUE];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_HCP);
            StudyDetailViewController.getTrialDetail(study.Id, CommunityService.USER_MODE_HCP);
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, null,null);
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
            HelpController.createCase('Some case','Seme Description', 'Question', 'Low', 'Some Reason', JSON.serialize(files), false, false);
            InfoModalController.getHCPEnrollmentHistory(hcpEnrollment.Id);
            InfoModalController.getStudySiteHistory(studySite.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void baseHCPTest2() {
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Terms_And_Conditions__c studyTC = [SELECT Id FROM Terms_And_Conditions__c WHERE Active__c != TRUE];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        update hcpEnrollment;
        
        System.runAs(hcpUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_SendSiteRequestByHCPRemote.changeStudyForHCP(studySite.Id, hcpEnrollment.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void baseHCPTest3() {
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Terms_And_Conditions__c studyTC = [SELECT Id FROM Terms_And_Conditions__c WHERE Active__c != TRUE];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;
        hcpEnrollment.Status__c = HCPEnrollmentService.HCP_S_INVITATION_SENT;
        update hcpEnrollment;
        
        System.runAs(hcpUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_SendSiteRequestByHCPRemote.selectNoSites(hcpEnrollment.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void baseHCPTest4() {
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_HCP);
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_PI);
            ApplicationHelpRemote.getInitData(CommunityService.USER_MODE_PARTICIPANT);
            //ShareModalController.sendEmail(hcpEnrollment.Id, hcpContact.Id, 'Some@mail.com', 'SOCIAL_SHARING');
            SendEmailTemplate.sendShareEmail(hcpEnrollment.Id, hcpContact.Id, 'Some@mail.com', 'Share_Social_Study_Template');
            ShareModalController.sendEmail(hcpEnrollment.Id, hcpContact.Id, 'Some@mail.com', null);
        }
        Test.stopTest();
    }
    @IsTest
    static void baseHCPTest5() {
        Study_Site__c studySite = [SELECT Id, Clinical_Trial_Profile__c FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            String initDataString = MyReferringClinicsController.getInitData(studySite.Clinical_Trial_Profile__c, studySite.Id);
            MyReferringClinicsController.InitData initData= (MyReferringClinicsController.InitData)JSON.deserializeStrict(initDataString, MyReferringClinicsController.InitData.class);
            MyReferringClinicsController.searchReferringClinics(JSON.serialize(initData.referringClinicsFilter.filterValues),JSON.serialize(initData.referringClinicsFilter.sortData),JSON.serialize(initData.paginationData), false);
            MyReferringClinicsController.searchReferringClinics(JSON.serialize(initData.referringClinicsFilter.filterValues),JSON.serialize(initData.referringClinicsFilter.sortData),JSON.serialize(initData.paginationData), true);
        }
        Test.stopTest();
    }

    @IsTest
    static void baseHCPTest6() {
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            Action_RequestToReferByHCPRemote.requestToReferForHCP(studySite.Id,hcpEnrollment.Id, null);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void emailTemplateController() {
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Contact piDelegateContact = [SELECT Id FROM Contact WHERE Email = 'pi_delegate@emil.com'];
        Participant_Enrollment__c   passedMrrPE = [SELECT Id FROM Participant_Enrollment__c WHERE Patient_ID__c = 'SomePatienntId2'];
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
        
        EmailActionBtnController emailActionBtnController = new EmailActionBtnController();
        String url = emailActionBtnController.getResultURL();
        url = emailActionBtnController.getResultURL();
        
        Test.stopTest();
    }
    
    @IsTest
    static void slideTour() {
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
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
        CountryStateUtil.getStateCodeByNameMap('US');
        TranslateHelper.convertBrowserLanguage(new List<String>{
                'en-US', 'it'
        });
    
    }
    
    
    @IsTest
    static void exportImportRemote() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        String languageLocale;
        Schema.DescribeFieldResult fieldResult = Translation__c.Language__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getValue()!='en_US'){
                languageLocale =pickListVal.getValue();
                break;
            }
        }
        Test.startTest();
        String exportXML = TranslationExportImportRemote.export(study.Id, languageLocale, TranslationExportImportRemote.EXPORT_TYPE_BILINGUAL);
        TranslationExportImportRemote.importTranslation(EncodingUtil.base64Encode(Blob.valueOf(exportXML)));
        Test.stopTest();
    }
//
//    @IsTest
//    static void batchUpdateRecordsTest() {
//        Test.startTest();
//        Batch_UpdateRecords.run();
//        Test.stopTest();
//    }
    
    @IsTest
    static void myStudySiteDetail() {
//        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
//        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
//        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
//        Test.startTest();
//        System.runAs(hcpUser) {
//            MyStudySitesController.getStudySiteDetail(study.Id);
//        }
//        Test.stopTest();
    }
    
    @IsTest
    static void hcpDelegateTest() {
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_HCP, null);
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_HCP, 'hcp_delegate@emil.com', null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevel.delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]),hcpContact.Id);
            detail.delegates[0].trialLevel.delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]),hcpContact.Id);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_HCP, 'hcp_delegate_new@emil.com',null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevel.delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New HCP Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New HCP Delegate';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]), hcpContact.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void piDelegateTest() {
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Test.startTest();
        System.runAs(piUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, null);
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_PI, 'pi_delegate@emil.com', null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]), null);
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]), null);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_PI, 'pi_delegate_new@emil.com', null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New PI Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New PI Delegate';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]), null);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void basePITest1() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        Test.startTest();
        System.runAs(piUser) {
            StudyListViewController.getStudyTrialList(CommunityService.USER_MODE_PI);
            StudyDetailViewController.getTrialDetail(study.Id, CommunityService.USER_MODE_PI);
            StudyDetailAboutStudyRemote.setTrialAcceptedForPI(study.Id, null,null);
            DashboardRemote.getInitData(CommunityService.USER_MODE_HCP, null,null);
            AccountSettingsController.getInitData(CommunityService.USER_MODE_HCP);
            AccountSettingsController.changeEmail('new@emil.com');
            AccountSettingsController.changePassword('Dd231324d13', 'Dd231324d13', '11111');
            ClinicProfileRemote.getClinicProfileData(hcpAccount.Id);
            CommunityFacadeRemote.getCommunityData();
            CommunityFacadeRemote.changeMode(CommunityService.USER_MODE_PI, null, null);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void basePITest2() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        Account studySiteAccount = [SELECT Id FROM Account WHERE Name = 'Study Site Account'];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Participant__c   participant = [SELECT Id FROM Participant__c WHERE Email__c = 'part1@email.com'];
        Test.startTest();
        System.runAs(piUser) {
            String vpResultJSON = ViewPatientsRemote.getInitData(study.Id, studySite.Id, CommunityService.USER_MODE_PI, null, CommunityService.USER_MODE_PI, null);
            ViewPatientsRemote.InitData vpResult = (ViewPatientsRemote.InitData) JSON.deserialize(vpResultJSON, ViewPatientsRemote.InitData.class);
//            ViewPatientsRemote.getStatistics(CommunityService.USER_MODE_PI, null);
            ViewPatientsRemote.getInitDataForPatientProfile(participant.Id, CommunityService.USER_MODE_PI, null);
//            ViewPatientsRemote.getStatistics(CommunityService.USER_MODE_PI, null);
            ViewPatientsRemote.getRecords(JSON.serialize(vpResult.peFilter), JSON.serialize(vpResult.paginationData), 'Pending', CommunityService.USER_MODE_PI, false, null);
            StudyClinicDashboardRemote.getInitData(study.Id, studySiteAccount.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void basePITest3() {
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Terms_And_Conditions__c studyTC = [SELECT Id FROM Terms_And_Conditions__c WHERE Active__c != TRUE];
        Participant_Enrollment__c   passedMrrPE = [SELECT Id FROM Participant_Enrollment__c WHERE Patient_ID__c = 'SomePatienntId2'];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Test.startTest();
        System.runAs(piUser) {
            TermsAndConditionsRemote.acceptTC(studyTC.Id);
            Action_ChangeHCPStatusByPIRemote.getEnrollmentReasonOptions();
            Action_ChangeHCPStatusByPIRemote.changeHCPEnrollmentStatus(hcpEnrollment.Id, StudyActions.ACT_HCP_ON_HOLD, '');
            Action_ChangeHCPStatusByPIRemote.changeHCPEnrollmentStatus(hcpEnrollment.Id, StudyActions.ACT_HCP_ACTIVATE_FOR_ALL, '');
            Action_ChangePEStatusByPIRemote.getReferralDeclineReasons();
            Action_ChangePEStatusByPIRemote.updatePE(JSON.serialize(passedMrrPE), PEStatusState.PE_STATUS_REFERRAL_ON_HOLD, '', '');
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest4() {
//        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
//        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        Test.startTest();
        System.runAs(piUser) {
            String initDataString = StudyListViewController.getPIInitData();
            StudyListViewController.PIInitData initData = (StudyListViewController.PIInitData) JSON.deserializeStrict( initDataString, StudyListViewController.PIInitData.class);
            StudyListViewController.searchStudiesPI(JSON.serialize(initData.piStudiesFilter.filterData),JSON.serialize(initData.piStudiesFilter.sortData), JSON.serialize(initData.paginationData));
        }
        Test.stopTest();
    }

    @IsTest
    static void basePITest5() {
//        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
//        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        Test.startTest();
        System.runAs(piUser) {
            Action_InviteRPRemote.getInviteDetail();
            Action_InviteRPRemote.inviteNewHCP('test', 'hcp', '12345','test@mail.com.fake', null, 'test-protocol',new List<String>());
        }
        Test.stopTest();
    }


    @IsTest
    static void healthcareProvidersTest() {
//        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Participant_Enrollment__c   pe = [SELECT Id FROM Participant_Enrollment__c WHERE Patient_ID__c = 'SomePatienntId2'];
//        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];
        Test.startTest();
        System.runAs(piUser) {
            Healthcare_Provider__c provider =  new Healthcare_Provider__c(
                    First_Name__c = 'testHP',
                    Last_Name__c = 'Lastname',
                    Email__c = 'testHP@mail.com.fake',
                    Participant_Enrollment__c = pe.Id
            );

            Healthcare_Provider__c hp = ReferHealthcareProviderRemote.inviteHP(pe.Id,JSON.serialize(provider))[0];
            ReferHealthcareProviderRemote.checkDuplicate(pe.Id,'testHP@mail.com.fake');
            ReferHealthcareProviderRemote.stopSharing(hp.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void accountSettingsControllerTest() {
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Participant__c   participant = [SELECT Id, Name FROM Participant__c WHERE Email__c = 'part1@email.com'];
        User participantUser = [SELECT Id FROM User WHERE Contact.LastName = :participant.Name];
        Test.startTest();
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
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Test.startTest();
        System.runAs(piUser) {
//            MyReferredZoneController.getStatusOptions(CommunityService.USER_MODE_PI);
//            MyReferringClinicsController.getClinicDetail(study.Id, CommunityService.USER_MODE_PI,null,false);
//            MyReferringClinicsController.getEnrollmentData(hcpEnrollment.Id, CommunityService.USER_MODE_PI);
        
        }
        Test.stopTest();
    }
    
    @IsTest
    static void referralProfileTest() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Participant_Enrollment__c   passedMrrPE = [SELECT Id FROM Participant_Enrollment__c WHERE Patient_ID__c = 'SomePatienntId2'];
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Test.startTest();
        System.runAs(piUser) {
            ReferralProfileRemote.getReferralProfileDetail(passedMrrPE.Id, CommunityService.USER_MODE_PI);
            //ReferralProfileRemote.getPEStatusHistory(passedMrrPE.Id, CommunityService.USER_MODE_PI, null);
            ReferralProfileRemote.changePEStatusByBtn(passedMrrPE.Id, 'Referral Accepted');
            //ReferralProfileRemote.changePEStatus(passedMrrPE.Id, 'Contact Successful', 'Some Notes', CommunityService.USER_MODE_PI);
            ReportsRemote.getInitData(study.Id, CommunityService.USER_MODE_PI, null);
            RRIconTableController.getFilterInfoAndSummaryInfo();
            RRProfileController.getUser();
            RRProfileController.getLogoutURL();
            //ShareModalController.sendEmail(study.Id, 'someemail@mail.com');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void mrrTest() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            String jsonResult = MedicalRecordReviewRemote.getInitData(study.Id, hcpEnrollment.Id, null);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void mrrAndReferringTest1() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        HCP_Enrollment__c hcpEnrollment = [SELECT Id FROM HCP_Enrollment__c WHERE Study_Site__c = :studySite.Id];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            //MedicalRecordReviewRemote.getHCPEnrolment(study.Id);
            String jsonResult = MedicalRecordReviewRemote.createParticipantEnrollment(study.Id, 'participan01', 'AAA', 'BBB', null);
            MedicalRecordReviewRemote.SearchPEResult searchPEResult = (MedicalRecordReviewRemote.SearchPEResult) JSON.deserialize(jsonResult, MedicalRecordReviewRemote.SearchPEResult.class);
            String peJSON = JSON.serialize(searchPEResult.pe);
            MedicalRecordReviewRemote.setMRRStatus(peJSON, ParticipantEnrollmentService.PES_STATUS_PASS, 'https://link.test');
            Participant_Enrollment__c pe = [SELECT Id FROM Participant_Enrollment__c LIMIT 1];
            String refInitDataJSON = ReferringRemote.getInitData(study.Id, pe.Id, hcpEnrollment.Id, CommunityService.USER_MODE_HCP, null);
            ReferringRemote.InitData refInitData = (ReferringRemote.InitData) JSON.deserialize(refInitDataJSON, ReferringRemote.InitData.class);
            insert new Participant__c();
            Participant__c participant2 = new Participant__c(
                    First_Name__c = 'FN',
                    Last_Name__c = 'LN',
                    Phone__c = '12123123',
                    Email__c = 'NewTestPart@email.com'
            );
            ReferringRemote.saveParticipant(hcpEnrollment.Id, JSON.serialize(refInitData.participantEnrollment), JSON.serialize(participant2), null, null);
            participant2 = [SELECT Id, Contact__c FROM Participant__c WHERE First_Name__c = 'FN' AND Last_Name__c = 'LN' LIMIT 1];
        }
        Test.stopTest();
        String vpResultJSON = ViewPatientsRemote.getInitData(study.Id, studySite.Id, CommunityService.USER_MODE_HCP, null, CommunityService.USER_MODE_HCP, null);
        ViewPatientsRemote.InitData vpResult = (ViewPatientsRemote.InitData) JSON.deserialize(vpResultJSON, ViewPatientsRemote.InitData.class);
    }
    
    @IsTest
    static void mrrAndReferringTest2() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Participant__c   participant = [SELECT Id FROM Participant__c WHERE Email__c = 'part1@email.com'];
        Participant_Enrollment__c   mrrPE = [SELECT Id FROM Participant_Enrollment__c WHERE Patient_ID__c = 'SomePatienntId'];
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);

        Test.startTest();
        System.runAs(hcpUser) {
            //MedicalRecordReviewRemote.getHCPEnrolment(study.Id);
            
//            ViewPatientsRemote.getStatistics(CommunityService.USER_MODE_HCP, null);
            ViewPatientsRemote.getInitDataForPatientProfile(participant.Id, CommunityService.USER_MODE_HCP, null);
            String mrrLogResStr = MedicalRecordReviewLogController.getParticipantDetail(study.Id, CommunityService.USER_MODE_HCP, false, null);
            mrrLogResStr = MedicalRecordReviewLogController.getParticipantDetail(null, CommunityService.USER_MODE_HCP, false,null);
            MedicalRecordReviewLogController.ParticipantDetail participantDetail = (MedicalRecordReviewLogController.ParticipantDetail) JSON.deserialize(mrrLogResStr, MedicalRecordReviewLogController.ParticipantDetail.class);
            MedicalRecordReviewLogController.getRecords(JSON.serialize(participantDetail.peFilter), JSON.serialize(participantDetail.paginationData), false, null);
            MedicalRecordReviewLogItemController.changeStatusToExcludeFromReferring(mrrPE.Id);
            ExcelController excelController = new ExcelController();
            excelController.getPEList();
            excelController.getHCPEList();
        }
        Test.stopTest();
    }
    
    @IsTest
    static void excelReportTest() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
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
        Study_Site__c studySite = [SELECT Id, Study_Site_Type__c FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Participant_Enrollment__c   passedMrrPE = [SELECT Id FROM Participant_Enrollment__c WHERE Patient_ID__c = 'SomePatienntId2'];
        studySite.Study_Site_Type__c = 'Virtual';
        update studySite;
        Test.setMock(HttpCalloutMock.class, new IntegrationCalloutMock());
        Test.startTest();
        System.runAs(hcpUser) {
            IntegrationService.sendPEToStudyHub(passedMrrPE.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void integrationServiceNowTest() {
        Study_Site__c studySite = [SELECT Id, Study_Site_Type__c FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Participant_Enrollment__c   passedMrrPE = [SELECT Id FROM Participant_Enrollment__c WHERE Patient_ID__c = 'SomePatienntId2'];
        studySite.Study_Site_Type__c = 'Virtual';
        update studySite;
        Test.setMock(HttpCalloutMock.class, new IntegrationCalloutMock());
        Test.startTest();
        System.runAs(hcpUser) {
            IntegrationService.sendPEToServiceNow(passedMrrPE.Id);
        }
        Test.stopTest();
    }
    @IsTest
    static void sitesSearchTest() {
        Clinical_Trial_Profile__c study = [SELECT Id FROM Clinical_Trial_Profile__c WHERE NCT_Number__c = 'NCT00000001'];
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        User hcpUser = [SELECT Id FROM User WHERE ContactId = :hcpContact.Id];
        Test.startTest();
        System.runAs(hcpUser) {
            //MedicalRecordReviewRemote.getHCPEnrolment(study.Id);
            String jsonResult = SitesSearchRemote.getInitData(study.Id, null);
            SitesSearchRemote.InitData data = (SitesSearchRemote.InitData)JSON.deserialize(jsonResult, SitesSearchRemote.InitData.class);
            SitesSearchRemote.getRecords(JSON.serialize(data.siteFilter),JSON.serialize(data.PaginationData), null);
        
        }
        Test.stopTest();
    }
    
//    @IsTest
//    static void testSaveNewAddress() {
//        Study_Site__c studySite = [SELECT Id FROM Study_Site__c WHERE Study_Site_Type__c = 'Traditional'];
//        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
//        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
//        Test.startTest();
//        Account testAccount = new Account(Name = 'Test Name', BillingStreet = 'BillingStreet');
//        insert testAccount;
//        studySite.Site__c = testAccount.Id;
//        update studySite;
//        studySite = [SELECT Id, Principal_Investigator__c, Name, Site__r.ParentId, Site__r.Name,Site__r.Id,Site__r.BillingStreet FROM Study_Site__c WHERE Id = :studySite.Id];
//        String ssId;
//        System.runAs(piUser) {
//            studySite.Site__r.BillingStreet = 'Test Street';
//            ssId = studySite.Site__r.Id;
//            studySite.Site__r.Id = null;
//            String status = StudyListViewController.saveSSAddress(JSON.serialize(studySite));
//        }
//        Study_Site__c testStudySite = [SELECT Id, Principal_Investigator__c, Name, Site__r.ParentId,Site__r.Name, Site__r.BillingStreet FROM Study_Site__c WHERE Id = :studySite.Id];
//        System.assertNotEquals(ssId, testStudySite.Site__r.Id);
//        System.runAs(piUser) {
//            testStudySite.Site__r.BillingStreet = 'Test Street 2';
//            String status2 = StudyListViewController.saveSSAddress(JSON.serialize(testStudySite));
//        }
//        Study_Site__c testStudySite2 = [SELECT Id, Name, Principal_Investigator__c, Site__r.ParentId,Site__r.Name, Site__r.BillingStreet FROM Study_Site__c WHERE Site__r.BillingStreet = 'Test Street 2'];
//        System.assertEquals(testStudySite2.Site__r.ParentId, testStudySite.Site__r.Id);
//        System.runAs(piUser) {
//            testStudySite2.Site__r.BillingStreet = 'Test Street 3';
//            String status3 = StudyListViewController.saveSSAddress(JSON.serialize(testStudySite2));
//        }
//        Study_Site__c testStudySite3 = [SELECT Id, Name, Principal_Investigator__c, Site__r.ParentId,Site__r.Name, Site__r.BillingStreet FROM Study_Site__c WHERE Site__r.BillingStreet = 'Test Street 3'];
//        System.assertEquals(testStudySite2.Site__r.Id, testStudySite3.Site__r.Id);
//        Test.stopTest();
//    }
    
    
    @IsTest
    static void testSaveSSDetails() {
        Contact piContact = [SELECT Id FROM Contact WHERE Email = 'pi@emil.com'];
        Study_Site__c studySite = [SELECT Id, Site_Staff__c, Study_Site_Email__c, Study_Site_Phone__c, Site__c FROM Study_Site__c WHERE Principal_Investigator__c = :piContact.Id];
        User piUser = [SELECT Id FROM User WHERE ContactId = :piContact.Id];
        Test.startTest();
        System.runAs(piUser) {
            studySite.Study_Site_Phone__c = '123456789';
            StudyListViewController.saveSSChanges(JSON.serialize(studySite));
        }
        Study_Site__c updatedSS = [SELECT Id, Site_Staff__c, Study_Site_Email__c, Study_Site_Phone__c, Site__c FROM Study_Site__c WHERE Id = :studySite.Id];
        System.assertEquals(studySite.Study_Site_Phone__c, updatedSS.Study_Site_Phone__c);
        Test.stopTest();
    }

}
