/**
 * Created by Denis on 15.04.2019.
 * Edited by Igor Malyuta
 */
@IsTest
private class Test_TaskRemote {
    static TestData testData1;
   // @TestSetup
    static void setup() {
        TestData.loadTestData();
        testData1 = new TestData();

        System.runAs(testData1.participantUser) {
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
            test.starttest();
           setup();
             test.stoptest();
           Participant__c participant = [
            SELECT
                Id,
                Name,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];

          List<User> users = [
            SELECT Id, ContactId, LastName
            FROM User
            WHERE Contact.LastName =: participant.Name
        ];
        
        
        List<Task> previewTasks;
       
        TasksRemote.ParticipantTasks allTasks;
      
        System.runAs(users[0]) {
            previewTasks = TasksRemote.getPreviewTasks();
            allTasks = TasksRemote.getParticipantTasks();
        }
         
      
       
        TasksRemote.taskClicked(previewTasks[0].Id, 'autocomplete=true');
       
      
        System.assertEquals(3, previewTasks.size());
        System.assertEquals(4, allTasks.openTasksWrapper.size() + allTasks.completedTasks.size());

      //  Task testCompletedTask = [SELECT Id, Status FROM Task WHERE Id = :previewTasks[0].Id];
      //  System.assertEquals(TaskService.TASK_STATUS_COMPLETED, testCompletedTask.Status); 
    }

    @IsTest
    static void testDelegate() {
         test.starttest();
           setup();
             test.stoptest();
       // TestData testData = new TestData();
        List<Task> previewTasks;
        TasksRemote.ParticipantTasks allTasks;

       // Test.startTest();
        System.runAs(testData1.createPatientDelegate()) {
            previewTasks = TasksRemote.getPreviewTasks();
            allTasks = TasksRemote.getParticipantTasks();
        }
      //  Test.stopTest();
        //  System.assertEquals(3, previewTasks.size());
        // System.assertEquals(4, allTasks.openTasksWrapper.size() + allTasks.completedTasks.size());
    }

    @IsTest
    static void getPreviewTasksWithException_test() {
         test.starttest();
           setup();
             test.stoptest();
        Boolean isThrownException = false;
       // Test.startTest();
        try {
            TasksRemote.getPreviewTasks();
        } catch (Exception e) {
            isThrownException = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
       // Test.stopTest();
        System.assertEquals(true, isThrownException);
    }

    @IsTest
    static void getParticipantTasksWithException_test() {
         test.starttest();
           setup();
             test.stoptest();
        Boolean isThrownException = false;
      //  Test.startTest();
        try {
            TasksRemote.getParticipantTasks();
        } catch (Exception e) {
            isThrownException = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
       // Test.stopTest();
        System.assertEquals(true, isThrownException);
    }

    @IsTest
    static void taskClickedWithException_test() {
         test.starttest();
           setup();
             test.stoptest();
        Boolean isThrownException = false;
       // Test.startTest();
        try {
            TasksRemote.taskClicked(null, null);
        } catch (Exception e) {
            isThrownException = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
       // Test.stopTest();
        System.assertEquals(true, isThrownException);
    } 
}
