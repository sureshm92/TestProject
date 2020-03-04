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
}


