/**
 * Created by Denis on 15.04.2019.
 * Edited by Igor Malyuta
 */
@IsTest
private class Test_TaskRemote {

    @IsTest
    static void getInitData() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Task task = new Task();
        insert task;

        Test.startTest();
        System.runAs(testData.participantUser) {
            TasksRemote.getPreviewTasks();
            TasksRemote.getParticipantTasks();
        }
        Test.stopTest();
    }
}