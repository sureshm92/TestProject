/**
* Created by Andrii Kryvolap.
*/

@IsTest(IsParallel=false)
private class Test_ParticipantInformationRemote {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }
    
    
    @IsTest
    static void getInitData() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            ParticipantInformationRemote.getInitData();
            ParticipantInformationRemote.getSteps(testData.pe.Id, CommunityService.USER_MODE_PI, null);
            ParticipantInformationRemote.getPrintInformation(testData.pe.Id, CommunityService.USER_MODE_PI, null);
            ParticipantInformationRemote.getPrintInfoWithSteps(testData.pe.Id, CommunityService.USER_MODE_PI, null);
        }
        Test.stopTest();
    }
    @IsTest
    static void updateState() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_PI);
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(testData.ctp, pe);
            path.steps[path.currentStepInd].outcome = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
            ParticipantInformationRemote.updatePatientInfoAndStatus(JSON.serialize(testData.participant), JSON.serialize(testData.pe), JSON.serialize(path), testData.pe.Id);
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdatePatientInfo() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_PI);
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(testData.ctp, pe);
            ParticipantInformationRemote.updatePatientInfo(JSON.serialize(testData.participant), JSON.serialize(testData.pe));
            try {
                ParticipantInformationRemote.createUserForPatientProtal(JSON.serialize(testData.pe), true);
            } catch(Exception e){
                System.debug('Exception');
            }
            ParticipantInformationRemote.getParticipantDelegates(JSON.serialize(testData.participant.Id));
            ParticipantInformationRemote.updateUserLanguage(JSON.serialize(testData.participantUser));
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateParticipant() {
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant;
        Test.startTest();
        AddPatientByPIRemote.updateParticipant(JSON.serialize(participant));
        Test.stopTest();
    }
    @IsTest
    static void testCreateParticipantDelegate() {
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';

        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        Test.startTest();
        AddPatientByPIRemote.createParticipantDelegate(JSON.serialize(participantDel), null, participant.Id, JSON.serialize(participant));
        Test.stopTest();
    }

    @IsTest
    static void updateStateCC() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_CC);
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(testData.ctp, pe);
            path.steps[path.currentStepInd].outcome = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
            ParticipantInformationRemote.updatePatientStatusCC( JSON.serialize(path), testData.pe.Id,false);
        }
        Test.stopTest();
    }
}