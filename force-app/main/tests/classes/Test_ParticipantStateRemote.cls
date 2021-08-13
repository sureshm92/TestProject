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
        System.runAs(testData.participantUser) {
            ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PARTICIPANT
            );
        }
        ParticipantItem initData = (ParticipantItem) JSON.deserialize(
            ParticipantStateRemote.getInitData(),
            ParticipantItem.class
        );
        //System.assertEquals(testData.pe.Name, initData.pe.Name);
    }

    @IsTest
    static void getParticipantNameTest() {
        TestData testData = new TestData();
        System.runAs(testData.participantUser) {
            ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PARTICIPANT
            );
        }
        System.assertEquals(
            testData.participant.First_Name__c +
            ' ' +
            testData.participant.Last_Name__c,
            ParticipantStateRemote.getParticipantName()
        );
    }
}