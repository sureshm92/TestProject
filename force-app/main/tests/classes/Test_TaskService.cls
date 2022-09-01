/**
 * Created by user on 02-May-19.
 */

@IsTest(IsParallel=false)
private class Test_TaskService {
    public class ParticipantServiceMock implements System.StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getState') {
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @IsTest
    static void getTasksTest() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(ParticipantTriggerHandler.UpdateNameOnPE.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TestData.loadTestData();
        TestData testData = new TestData();
        Task task = new Task();
        task.Subject = 'Test';
        task.OwnerId = testData.participantUser.Id;
        task.Visible_For__c = 'Owner';
        Task taskIgnore = new Task();
        taskIgnore.Subject = 'TestI';
        taskIgnore.OwnerId = testData.participantUser.Id;
        taskIgnore.Visible_For__c = 'Owner';
        List<Task> tasks = new List<Task>{ task, taskIgnore };
        insert tasks;

        List<Task> testOpenTasks;
        List<Task> testPreviewTasks;
        List<Task> testCompletedTasks;
        TaskService.TaskConfig taskConfig;
        Test.startTest();
        insert TaskService.getInstance()
            .createCompleteYourProfileTask(
                testData.participantUser.Id,
                testData.participant.Id,
                testData.participant.Contact__c
            );
        System.runAs(testData.participantUser) {
            testOpenTasks = TaskService.getInstance().getOpenTasks();
            testPreviewTasks = TaskService.getInstance().getPreviewTasks();

            TaskService.getInstance().completeTask(task.Id);
            TaskService.getInstance().ignoreTask(taskIgnore.Id);
            TaskService.getInstance().completeCYPTaskForParticipant();
            testCompletedTasks = TaskService.getInstance().getCompletedTasks();

            taskConfig = new TaskService.TaskConfig(
                task.OwnerId,
                null,
                task.Subject,
                task.Visible_For__c
            );
        }
        //Test.stopTest();
        System.assertEquals(3, testOpenTasks.size());
        System.assertEquals(3, testPreviewTasks.size());

        Task complTask = [SELECT Id, Subject, Status FROM Task WHERE Id = :task.Id];
        System.assertEquals(TaskService.TASK_STATUS_COMPLETED, complTask.Status);
        System.assertEquals(complTask.Subject, taskConfig.subject);

        Task ignoreTask = [SELECT Id, Status FROM Task WHERE Id = :taskIgnore.Id];
        System.assertEquals(TaskService.TASK_STATUS_IGNORED, ignoreTask.Status);

        Test.stopTest();
        Task cypTask = [
            SELECT Id, Status
            FROM Task
            WHERE Task_Code__c = :TaskService.TASK_CODE_COMPLETE_YOUR_PROFILE
        ];
        System.assertEquals(TaskService.TASK_STATUS_COMPLETED, cypTask.Status);
        System.assertEquals(3, testCompletedTasks.size());
    }
}
