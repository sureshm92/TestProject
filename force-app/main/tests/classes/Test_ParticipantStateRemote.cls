/**
 * Created by Igor Malyuta on 04.07.2019.
 */

@IsTest
private class Test_ParticipantStateRemote {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void getInitDataTest() {
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_PARTICIPANT);
        }
        ParticipantStateRemote.getInitData();
    }

    @IsTest
    static void getParticipantNameTest() {
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_PARTICIPANT);
        }

        ParticipantStateRemote.getParticipantName();
    }
}