/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_StudyActionParticipant {
    @IsTest
    static void test1() {
        StudyActionsParticipant studyActionsParticipant;

        TestData.loadTestData();
        Test.startTest();
        TestData testDataInstance = new TestData();
        System.runAs(testDataInstance.participantUser) {
            studyActionsParticipant = new StudyActionsParticipant();
        }
        Test.stopTest();
        System.assertEquals(3, studyActionsParticipant.studyDetailActions.size());
    }
}
