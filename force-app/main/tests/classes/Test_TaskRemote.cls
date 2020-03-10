/**
 * Created by Denis on 15.04.2019.
 * Edited by Igor Malyuta
 */
@IsTest
private class Test_TaskRemote {


    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void getInitData() {
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