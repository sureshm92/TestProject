/**
 * Created by Denis on 15.04.2019.
 * Edited by Igor Malyuta
 */
@IsTest
private class Test_TaskRemote {

    @TestSetup
    static void setup() {
        TestData.loadTestData();
        TestData testData = new TestData();

        System.runAs(testData.participantUser) {
            List<Task> tasks = new List<Task>();
            Task openTask = new Task(
                    Status = TaskService.TASK_STATUS_OPEN,
                    Activity_Datetime__c = Datetime.now(),
                    ReminderDateTime = Datetime.now(),
                    Visible_For__c = TaskService.TASK_VISIBILITY_ALL
            );
            Task completedTask = new Task(
                    Status = TaskService.TASK_STATUS_COMPLETED,
                    Completed_Date__c = Datetime.now(),
                    Visible_For__c = TaskService.TASK_VISIBILITY_ALL
            );
            tasks.add(openTask);
            tasks.add(completedTask);
            insert tasks;
        }
    }

    @IsTest
    static void getInitData() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.participantUser) {
            TasksRemote.getPreviewTasks();
            TasksRemote.getParticipantTasks();
        }
        Test.stopTest();
    }

    @IsTest
    static void testDelegate() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.createPatientDelegate()) {
            TasksRemote.getPreviewTasks();
            TasksRemote.getParticipantTasks();
        }
        Test.stopTest();
    }
}