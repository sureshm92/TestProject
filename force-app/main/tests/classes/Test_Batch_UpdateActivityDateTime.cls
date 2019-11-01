/**
 * Created by Olga Skrynnikova on 10/31/2019.
 */

@IsTest
private class Test_Batch_UpdateActivityDateTime {
    @IsTest
    static void batchExecute() {
        TestData.loadTestData();
        User user = [SELECT Id FROM User WHERE Contact.Name LIKE 'P%' LIMIT 1];
        List<Task> tasksList = new List<Task>();
            Task task1 = new Task(
                    Reminder_Date__c = Datetime.now(),
                    Subject = 'Some',
                    OwnerId = user.Id,
                    ActivityDate = Date.today()
            );
            Task task2 = new Task(
                    Reminder_Date__c = Datetime.now(),
                    Subject = 'Some 2',
                    OwnerId = user.Id,
                    ActivityDate = Date.today()
            );
            tasksList.add(task1);
            tasksList.add(task2);
        insert tasksList;

        Test.startTest();
        new Batch_UpdateActivityDateTimeOldUsers().execute(null, tasksList);
        Test.stopTest();

        System.assertEquals(Datetime.now().dateGmt(), tasksList[0].Activity_Datetime__c);
        System.assertEquals(2, tasksList.size());
    }
}