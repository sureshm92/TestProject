/**
 * Created by Denis on 12.04.2019.
 */
@IsTest
private class  Test_TaskEditRemote {

    @IsTest
    static void getInitTaskEditDataWrapper() {
        TestData.loadTestData();
        TestData testData = new TestData();
        Datetime dateNow = Datetime.now();

        Test.startTest();
        System.runAs(testData.participantUser) {
            List<Task> tasks = new List<Task>();
            Task task = new Task();
            task.Subject = 'test';
            task.Reminder_Date__c = dateNow;
            task.ActivityDate = Date.today().addDays(1);
            task.OwnerId = testData.participantUser.Id;
            task.Visible_For__c = 'Owner';
            Task task2 = new Task();
            task2.Subject = 'test2';
            task2.Reminder_Date__c = dateNow;
            task2.ActivityDate = Date.today().addDays(1);
            task2.OwnerId = testData.participantUser.Id;
            task2.Visible_For__c = 'Owner';
            tasks.add(task);
            tasks.add(task2);
            insert tasks;

            TaskEditRemote.getTaskEditData(task.Id);
            task.Reminder_Date__c = task.Reminder_Date__c.addDays(1);
            TaskEditRemote.upsertTask(JSON.serialize(new TaskEditRemote.TaskEditDataWrapper()), JSON.serialize(task));
            TaskEditRemote.markAsCompleted(task.Id);
            TaskEditRemote.deleteTask(task2);
        }
        Test.stopTest();
        List<Task> testTask = [SELECT Id, Status, Reminder_Date__c FROM Task WHERE Subject = 'test'];
        List<Task> testTask2 = [SELECT Id FROM Task WHERE Subject = 'test2'];
        System.assertEquals(dateNow.addDays(1), testTask[0].Reminder_Date__c);
        System.assertEquals(TaskService.TASK_STATUS_COMPLETED, testTask[0].Status);
        System.assert(testTask2.isEmpty());
    }
}
