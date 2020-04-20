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
    public static void init(){
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    static void test_AddPatientByPIRemote_getInitData() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.piUser){
            AddPatientByPIRemote.getInitData(testDataInstance.ss.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void test_AddPatientByPIRemote_saveParticipant() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.piUser){
            String userLanguage = 'ru';
            Participant__c participant = new Participant__c(
                    First_Name__c = 'NewP',
                    Last_Name__c = 'NewP',
                    Phone__c = '11213232',
                    Email__c = 'NewP@email.com',
                    Mailing_Country_Code__c = 'US',
                    Mailing_State_Code__c = 'NY'
            
            );
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                    Study_Site__c = testDataInstance.ss.Id,
                    Patient_ID__c = '12345678',
                    Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
            );
            try{
                AddPatientByPIRemote.saveParticipant(JSON.serialize(participant), JSON.serialize(pe), userLanguage, testDataInstance.ss.Id, true);
                for(Participant_Enrollment__c pe2 : [SELECT Name, Referral_ID__c, Participant_Key__c FROM Participant_Enrollment__c]){
                    System.debug('XXX_PE: ' + pe2);
                }
            }catch (Exception e){
                System.debug('ERROR: ' + e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    static void test_AlertRemote() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser){
            List<Alert> alerts = (List<Alert>)JSON.deserialize(AlertsRemote.getAlerts(CommunityService.USER_MODE_PARTICIPANT), List<Alert>.class);
            AlertsRemote.setAlertViewed(alerts[0].id);
        }
        Test.stopTest();
    }

    @IsTest
    static void test_StudyDetailViewReceived() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser){
            StudyDetailViewController.getTrialDetail(testDataInstance.ctp.Id, CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }

    @IsTest
    static void test_StudyDetailViewParticipant() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        testDataInstance.updatePEStatusEnrollmentSuccess();
        System.runAs(testDataInstance.participantUser){
            StudyDetailViewController.getTrialDetail(testDataInstance.ctp.Id, CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }

    @IsTest
    static void test_StudyDetailViewAlumni() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        delete testDataInstance.pe;
        System.runAs(testDataInstance.participantUser){
            StudyDetailViewController.getTrialDetail(testDataInstance.ctp.Id, CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }

    @IsTest
    static void test_LanguageSwitcher() {
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser){
            LanguageSwitcherRemote.getInitData();
            LanguageSwitcherRemote.changeLanguage('en_US','','', 'en_US', 'Asia/Kathmandu');
        }
        Test.stopTest();
    }




}