/**
 * Created by user on 02-May-19.
 */

@IsTest(IsParallel=false)
private class Test_TaskService {

    public class ParticipantServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getState') {
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @IsTest
    static void getTasksTest() {
        //ParticipantService.setMock(new ParticipantServiceMock());
        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.participantUser){
            TaskService.getInstance().getOpenTasks();
            TaskService.getInstance().getPreviewTasks();
            Task task = new Task();
            task.Subject = 'Test';
            task.OwnerId = testData.participantUser.Id;
            task.Visible_For__c = 'Owner';
            insert task;

            TaskService.getInstance().getTask(task.Id);
            TaskService.getInstance().getCompletedTasks();
            TaskService.getInstance().ignoreTask(task.Id);
            TaskService.getInstance().completeTask(task.Id);
            TaskService.getInstance().completeTask(task);
            TaskService.getInstance().createCompleteYourProfileTask(null, null, null);
            TaskService.getInstance().getOpenTasksFilter();
            TaskService.getInstance().completeCYPTaskForParticipant();
            // For coverage
            TaskService.TaskConfig taskConfig = new TaskService.TaskConfig(task.OwnerId, null, task.Subject, task.Visible_For__c);
        }
        Test.stopTest();
    }
}