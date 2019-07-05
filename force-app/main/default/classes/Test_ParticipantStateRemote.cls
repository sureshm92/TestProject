/**
 * Created by Igor Malyuta on 04.07.2019.
 */

@IsTest
private class Test_ParticipantStateRemote {

    @IsTest
    static void getInitDataTest() {
        TestData.loadTestData();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_PARTICIPANT);
        }
        ParticipantStateRemote.getInitData();
    }

    @IsTest
    static void getParticipantNameTest() {
        TestData.loadTestData();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_PARTICIPANT);
        }

        ParticipantStateRemote.getParticipantName();
    }
}