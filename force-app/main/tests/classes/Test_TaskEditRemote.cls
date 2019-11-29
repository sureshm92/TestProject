/**
 * Created by Denis on 12.04.2019.
 */
@IsTest
private class  Test_TaskEditRemote {

    @IsTest
    static void getInitTaskEditDataWrapper() {
        TestData.loadTestData();
        TestData testData = new TestData();

        Task task = new Task();
        task.Subject = 'test';
        task.Reminder_Date__c = Datetime.now();
        task.ActivityDate = Date.today().addDays(1);

        Test.startTest();
        System.runAs(testData.participantUser) {
            insert task;
            TaskEditRemote.getTaskEditData(task.Id);
            task.Reminder_Date__c = task.Reminder_Date__c.addDays(1);
            TaskEditRemote.upsertTask(JSON.serialize(new TaskEditRemote.TaskEditDataWrapper()), JSON.serialize(task));
            TaskEditRemote.markAsCompleted(task.Id);
            TaskEditRemote.deleteTask(task);
        }
        Test.stopTest();
    }
}
