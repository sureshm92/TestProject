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
            Task openTask1 = new Task(
                    Status = TaskService.TASK_STATUS_OPEN,
                    Activity_Datetime__c = Datetime.now(),
                    ReminderDateTime = Datetime.now(),
                    Visible_For__c = TaskService.TASK_VISIBILITY_ALL,
                    Originator__c = 'Participant'
            );
            Task openTask2 = new Task(
                    Status = TaskService.TASK_STATUS_OPEN,
                    Activity_Datetime__c = Datetime.now(),
                    ReminderDateTime = Datetime.now(),
                    Visible_For__c = TaskService.TASK_VISIBILITY_ALL,
                    Originator__c = 'Delegate'
            );
            Task completedTask = new Task(
                    Status = TaskService.TASK_STATUS_COMPLETED,
                    Completed_Date__c = Datetime.now(),
                    Visible_For__c = TaskService.TASK_VISIBILITY_ALL
            );
            tasks.add(openTask);
            tasks.add(openTask1);
            tasks.add(openTask2);
            tasks.add(completedTask);
            insert tasks;
        }
    }

    @IsTest
    static void getInitData() {
        TestData testData = new TestData();
        List<Task> previewTasks;

        Test.startTest();
        System.runAs(testData.participantUser) {
            previewTasks = TasksRemote.getPreviewTasks();
            TasksRemote.getParticipantTasks();
        }
        TasksRemote.taskClicked(previewTasks[0].Id, 'autocomplete=true');
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

    @IsTest
    static void getPreviewTasksWithException_test() {
        Boolean isThrownException = false;
        Test.startTest();
        try {
            TasksRemote.getPreviewTasks();
        } catch(Exception e) {
            isThrownException = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assertEquals(true, isThrownException);
    }

    @IsTest
    static void getParticipantTasksWithException_test() {
        Boolean isThrownException = false;
        Test.startTest();
        try {
            TasksRemote.getParticipantTasks();
        } catch(Exception e) {
            isThrownException = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assertEquals(true, isThrownException);
    }

    @IsTest
    static void taskClickedWithException_test() {
        Boolean isThrownException = false;
        Test.startTest();
        try {
            TasksRemote.taskClicked(null, null);
        } catch(Exception e) {
            isThrownException = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        Test.stopTest();
        System.assertEquals(true, isThrownException);
    }
}
