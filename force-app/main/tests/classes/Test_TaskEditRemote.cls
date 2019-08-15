/**
 * Created by Denis on 12.04.2019.
 */

@IsTest
private class  Test_TaskEditRemote {

    @IsTest
    static void getInitTaskEditDataWrapper() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        testData.createPSE();

        System.runAs(testData.participantUser) {
            Task task = new Task();
            task.Subject = 'test';
            task.Task_Type__c = 'Medication';
            task.Reminder_Date__c = Datetime.now();
            insert task;

            new TaskEditRemote.TaskEditDataWrapper();
            TaskEditRemote.getTaskEditData(task.Id);
            task.Reminder_Date__c = task.Reminder_Date__c.addDays(1);
            TaskEditRemote.upsertTask(JSON.serialize(task), Date.today());
            TaskEditRemote.markAsCompleted(task.Id);
            TaskEditRemote.deleteTask(task);
        }

        Test.stopTest();
    }
}