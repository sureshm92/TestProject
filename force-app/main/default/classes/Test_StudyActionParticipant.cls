/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_StudyActionParticipant {
    
    @IsTest
    static void test1() {
        TestData.loadTestData();
        Test.startTest();
        TestData testData = new TestData();
        System.runAs(testData.participantUser){
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(testData.pe.Id, CommunityService.USER_MODE_PARTICIPANT);
            StudyActions studyActions = new StudyActionsParticipant(pe);
        }
        Test.stopTest();
    }
}