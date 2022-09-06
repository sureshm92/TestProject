/**
 * Created by Nargiz Mamedova on 8/17/2020.
 */

@IsTest
private class Test_CommunityModeSwitcherRemote {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testSwitcherPatient() {
        TestData testData = new TestData();
        String initData;
        String initDataAlumni;
        String logOutString;

        System.runAs(testData.participantUser) {
            initData = CommunityModeSwitcherRemote.getSwitcherInitData();
        }

        CommunityModeSwitcherRemote.CommunityModesWrapper result = (CommunityModeSwitcherRemote.CommunityModesWrapper) JSON.deserializeStrict(
            initData,
            CommunityModeSwitcherRemote.CommunityModesWrapper.class
        );
        System.assertEquals(CommunityModes.MODE_TYPE_PP_ONLY, result.communityModes.type);
        System.assertEquals(
            testData.ctp.Study_Code_Name__c,
            result.communityModes.ppModeItems[0].subItems[0].subTitle
        );

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_FAILED;
        update testData.pe;

        System.runAs(testData.participantUser) {
            initDataAlumni = CommunityModeSwitcherRemote.getSwitcherInitData();
            CommunityModeSwitcherRemote.getCommunityUserVisibility();
            logOutString = CommunityModeSwitcherRemote.getLogoutURL();
        }

        CommunityModeSwitcherRemote.CommunityModesWrapper resultAlumni = (CommunityModeSwitcherRemote.CommunityModesWrapper) JSON.deserializeStrict(
            initDataAlumni,
            CommunityModeSwitcherRemote.CommunityModesWrapper.class
        );
        System.assertEquals(CommunityModes.MODE_TYPE_PP_ONLY, resultAlumni.communityModes.type);
        System.assertEquals(
            Label.No_active_studies,
            resultAlumni.communityModes.ppModeItems[0].subItems[0].subTitle
        );
        System.assertEquals(
            false,
            logOutString.contains('janssen') || logOutString.contains('gsk')
        );
    }

    @IsTest
    static void testProspectView() {
        ClassFactory.putStubTypeByClassName(
            CommunityService.class,
            StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        TestData testData = new TestData();

        Contact prospect = new Contact(
            FirstName = 'Joy',
            LastName = 'JoyDad',
            Email = 'Joypatient@somemail.com',
            AccountId = testData.participant.Contact__r.AccountId,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT
        );
        insert prospect;
        Participant__c p = new Participant__c(
            First_Name__c = 'Joy',
            Last_Name__c = 'JoyDad',
            Email__c = 'Joypatient@somemail.com',
            Contact__c = prospect.Id
        );
        insert p;

        User prospectUser = CommunityService.createUser(prospect, null, null, null);
        String initData;

        Test.startTest();
        System.runAs(prospectUser) {
            initData = CommunityModeSwitcherRemote.getSwitcherInitData();
        }

        prospect.userCommunityMode__c = CommunityService.USER_MODE_HCP;
        prospect.userCommunytyType__c = CommunityService.USER_MODE_HCP;

        update prospect;
        System.runAs(prospectUser) {
            initData = CommunityModeSwitcherRemote.getSwitcherInitData();
        }
        Test.stopTest();

        System.assertNotEquals(null, initData, '');
    }

    @IsTest
    static void testSwitcherPatientDelegate() {
        TestData testData = new TestData();
        User patientDelUser = testData.createPatientDelegate();
        String initData;
        String initDataAlumni;

        System.runAs(patientDelUser) {
            initData = CommunityModeSwitcherRemote.getSwitcherInitData();
        }

        CommunityModeSwitcherRemote.CommunityModesWrapper result = (CommunityModeSwitcherRemote.CommunityModesWrapper) JSON.deserializeStrict(
            initData,
            CommunityModeSwitcherRemote.CommunityModesWrapper.class
        );
        //  System.assertEquals(CommunityModes.MODE_TYPE_PP_ONLY, result.communityModes.type);
        //  System.assertEquals(testData.ctp.Study_Code_Name__c, result.communityModes.ppModeItems[0].subItems[0].subTitle);

        testData.pe.Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_FAILED;
        update testData.pe;

        System.runAs(patientDelUser) {
            initDataAlumni = CommunityModeSwitcherRemote.getSwitcherInitData();
        }

        CommunityModeSwitcherRemote.CommunityModesWrapper resultAlumni = (CommunityModeSwitcherRemote.CommunityModesWrapper) JSON.deserializeStrict(
            initDataAlumni,
            CommunityModeSwitcherRemote.CommunityModesWrapper.class
        );
        System.assertEquals(CommunityModes.MODE_TYPE_PP_ONLY, resultAlumni.communityModes.type);
        System.assertEquals(
            Label.No_active_studies,
            resultAlumni.communityModes.ppModeItems[0].subItems[0].subTitle
        );
    }

    @IsTest
    static void testSwitcherPI() {
        TestData testData = new TestData();
        Contact piContact = [
            SELECT
                Id,
                Current_Participant_Enrollment__c,
                userCommunityMode__c,
                userCommunityDelegateId__c,
                Current_Sponsor_Name__c
            FROM Contact
            WHERE Id = :testData.piUser.ContactId
        ];
        String initData;

        Account studySiteAccount = [
            SELECT Id
            FROM Account
            WHERE Name = 'Study Site Account'
            LIMIT 1
        ];
        Terms_And_Conditions__c studyTC = [SELECT Id FROM Terms_And_Conditions__c LIMIT 1];
        Therapeutic_Area__c area = [SELECT Id FROM Therapeutic_Area__c LIMIT 1];

        Clinical_Trial_Profile__c janssenStudy = new Clinical_Trial_Profile__c(
            Protocol_ID__c = 'CTPJ1',
            Override_Recruitment_Status__c = 'Actively Enrolling',
            NCT_Number__c = 'NCT99999990',
            Link_to_Pre_screening__c = 'some link',
            Terms_And_Conditions_ID__c = studyTC.Id,
            Study_Title__c = 'Some Title',
            Study_Code_Name__c = 'Some Code Name',
            Suppress_Participant_Emails__c = false,
            Therapeutic_Area__c = area.Id,
            Synch_with_TMDH__c = true,
            Include_in_RP_trial_search__c = true,
            Patient_Portal_Enabled__c = true,
            Shareback_Settings_On_Participant_Level__c = true,
            Shareback_Availability_Timing__c = 1,
            Visit_Data_Shareback__c = true,
            Visit_Schedule_Is_Available__c = true,
            Tasks_Are_Available__c = true,
            Study_Documents_Are_Available__c = true,
            Video_And_Articles_Are_Available__c = true,
            Travel_Vendor_Is_Available__c = true,
            Relevant_Links_Are_Available__c = true,
            Sponsor_Pays_for_Referral_Activity__c = 'Yes',
            CommunityTemplate__c = CommunityTemplateService.TEMPLATE_JANSSEN,
            Logged_Out_Days_Notification__c = 1
        );
        insert janssenStudy;
        Study_Site__c janssenStudySite = new Study_Site__c(
            Principal_Investigator__c = testData.piContact.Id,
            Clinical_Trial_Profile__c = janssenStudy.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SSJ1',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code'
        );
        insert janssenStudySite;
        janssenStudySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update janssenStudySite;

        System.runAs(testData.piUser) {
            initData = CommunityModeSwitcherRemote.getSwitcherInitData();
        }
        CommunityModeSwitcherRemote.CommunityModesWrapper result = (CommunityModeSwitcherRemote.CommunityModesWrapper) JSON.deserializeStrict(
            initData,
            CommunityModeSwitcherRemote.CommunityModesWrapper.class
        );
        //System.assertEquals(CommunityModes.MODE_TYPE_RH_ONLY, result.communityModes.type);
        //System.assertEquals(2, result.communityModes.rhModeItems.size());
    }

    @IsTest
    static void testSwitcherHCP() {
        TestData testData = new TestData();
        Contact hcpContact = [
            SELECT
                Id,
                Current_Participant_Enrollment__c,
                userCommunityMode__c,
                userCommunityDelegateId__c,
                Current_Sponsor_Name__c,
                userCommunytyType__c
            FROM Contact
            WHERE Id = :testData.hcpUser.ContactId
        ];
        String initData;

        System.runAs(testData.hcpUser) {
            initData = CommunityModeSwitcherRemote.getSwitcherInitData();
        }
        CommunityModeSwitcherRemote.CommunityModesWrapper result = (CommunityModeSwitcherRemote.CommunityModesWrapper) JSON.deserializeStrict(
            initData,
            CommunityModeSwitcherRemote.CommunityModesWrapper.class
        );
        System.assertEquals(CommunityModes.MODE_TYPE_RH_ONLY, result.communityModes.type);
        System.assertEquals(
            Label.View_Mode +
            ' ' +
            Label.HCP_Mode,
            result.communityModes.rhModeItems[0].title
        );
    }
}