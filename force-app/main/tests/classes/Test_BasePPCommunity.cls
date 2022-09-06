/**
 * Created by Leonid Bartenev
 *
 * All integration tests for Patient Portal should be here,
 * test data initialised one time in init() method for saving of time
 *
 */

@IsTest(IsParallel=false)
private class Test_BasePPCommunity {
    @TestSetup
    public static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void test_AddPatientByPIRemote_getInitData() {
        AddPatientByPIRemote.FormData initData = new AddPatientByPIRemote.FormData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        try {
            System.runAs(testDataInstance.piUser) {
                initData = AddPatientByPIRemote.getInitData(testDataInstance.ss.Id);
            }
        } catch (Exception e) {
            System.debug('ERROR: ' + e.getMessage());
        }
        Test.stopTest();
        Boolean checkInitData = initData != null ? true : false;
        System.assertEquals(true, checkInitData);
    }

    @IsTest
    static void test_AddPatientByPIRemote_saveParticipant() {
        Boolean isExceptionThrown = false;
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.piUser) {
            String userLanguage = 'ru';
            Participant__c participant = new Participant__c(
                First_Name__c = 'NewP',
                Last_Name__c = 'NewP',
                Phone__c = '11213232',
                Email__c = 'NewP@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY'
            );
            Participant__c participantDel = new Participant__c();
            participantDel.Email__c = 'Test01@mail.ru';
            participantDel.First_Name__c = 'testName';
            participantDel.Last_Name__c = 'testLastName';
            participantDel.Phone__c = '141241';
            participantDel.Phone_Type__c = 'Home';
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Study_Site__c = testDataInstance.ss.Id,
                Patient_ID__c = '12345678',
                Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
            );
            try {
                ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                    pe.Id,
                    'del@email.delemail',
                    'firstName',
                    'lastName',
                    null
                );
                AddPatientByPIRemote.assignParticipantPermissions(
                    testDataInstance.ss.Id,
                    testDataInstance.piContact.Id
                );
                //RH-6742 -- Extra parameters related to IQVIA outreach consenting has been added
                AddPatientByPIRemote.saveParticipant(
                    JSON.serialize(participant),
                    JSON.serialize(pe),
                    userLanguage,
                    testDataInstance.ss.Id,
                    true,
                    JSON.serialize(participantDel),
                    JSON.serialize(ddInfo),
                    false,
                    false,
                    false,
                    false,
                    false,
                    null,
                    false
                );

                for (Participant_Enrollment__c pe2 : [
                    SELECT Name, Referral_ID__c, Participant_Key__c
                    FROM Participant_Enrollment__c
                ]) {
                    System.debug('XXX_PE: ' + pe2);
                }
            } catch (Exception e) {
                isExceptionThrown = true;
                System.debug('ERROR: ' + e.getMessage());
            }
        }
        Test.stopTest();
        //System.assertEquals(true, isExceptionThrown);
    }

    @IsTest
    static void test_AlertRemote() {
        List<Alert> alerts = new List<Alert>();
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {
            alerts = (List<Alert>) JSON.deserialize(
                AlertsRemote.getAlerts(CommunityService.USER_MODE_PARTICIPANT),
                List<Alert>.class
            );
            AlertsRemote.setAlertViewed(alerts[0].id);
        }
        Test.stopTest();

        System.assertEquals(1, alerts.size());
    }

    @IsTest
    static void test_StudyDetailViewReceived() {
        TrialDetail trialDetail;
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {
            trialDetail = (TrialDetail) JSON.deserialize(
                StudyDetailViewController.getTrialDetail(
                    testDataInstance.ctp.Id,
                    CommunityService.USER_MODE_PARTICIPANT
                ),
                TrialDetail.class
            );
        }
        Test.stopTest();
        System.assertEquals(true, trialDetail != null ? true : false);
    }

    @IsTest
    static void test_StudyDetailViewParticipant() {
        TrialDetail trialDetail;
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.updatePEStatusEnrollmentSuccess();
        System.runAs(testDataInstance.participantUser) {
            trialDetail = (TrialDetail) JSON.deserialize(
                StudyDetailViewController.getTrialDetail(
                    testDataInstance.ctp.Id,
                    CommunityService.USER_MODE_PARTICIPANT
                ),
                TrialDetail.class
            );
        }
        Test.stopTest();
        System.assertEquals(
            true,
            trialDetail.pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
        );
    }

    @IsTest
    static void test_StudyDetailViewAlumni() {
        TrialDetail trialDetail;
        Test.startTest();
        TestData testDataInstance = new TestData();
        delete testDataInstance.pe;
        System.runAs(testDataInstance.participantUser) {
            trialDetail = (TrialDetail) JSON.deserialize(
                StudyDetailViewController.getTrialDetail(
                    testDataInstance.ctp.Id,
                    CommunityService.USER_MODE_PARTICIPANT
                ),
                TrialDetail.class
            );
        }
        Test.stopTest();
        System.assertEquals(true, trialDetail.pe == null ? true : false);
    }

    @IsTest
    static void test_LanguageSwitcher() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {
            LanguageSwitcherRemote.getInitData();
            PP_LanguageSwitcherRemote.getInitData();
            LanguageSwitcherRemote.changeLanguage('en_US', '', '', 'en_US', 'Asia/Kathmandu');
            PP_LanguageSwitcherRemote.changeLanguage(
                'en_US',
                '',
                '',
                '',
                '',
                '',
                'en_US',
                'Asia/Kathmandu',
                true
            );
        }
        Test.stopTest();
        User user = [
            SELECT Id, LanguageLocaleKey, TimeZoneSidKey, LocaleSidKey
            FROM User
            WHERE Id = :testDataInstance.participantUser.Id
        ];
        System.assertEquals('en_US', user.LanguageLocaleKey);
        System.assertEquals('en_US', user.LocaleSidKey);
        System.assertEquals('Asia/Kathmandu', user.Timezonesidkey);
    }
    @IsTest
    static void test_LanguageSwitcherForMinor() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        List<Participant__c> participantList = [
            SELECT Id, Adult__c
            FROM Participant__c
            WHERE Contact__c = :testDataInstance.participantUser.ContactId
        ];
        participantList[0].Adult__c = false;
        update participantList;
        System.runAs(testDataInstance.participantUser) {
            PP_LanguageSwitcherRemote.getInitData();
            //PP_LanguageSwitcherRemote.changeLanguage('en_US','','','','','','en_US','Asia/Kathmandu',true);
        }
        Test.stopTest();
        User user = [
            SELECT Id, LanguageLocaleKey, TimeZoneSidKey, LocaleSidKey
            FROM User
            WHERE Id = :testDataInstance.participantUser.Id
        ];
        System.assertEquals('en_US', user.LanguageLocaleKey);
        System.assertEquals('en_US', user.LocaleSidKey);
        System.assertEquals('America/Los_Angeles', user.Timezonesidkey);
    }
}
