/**
 * Created by Denis on 15.04.2019.
 */

@IsTest(IsParallel=true)
private class Test_TaskRemote {

    public class TaskServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getPreviewTasks'){
                return new List<Task>();
            } else if(stubbedMethodName == 'getOpenTasks'){
                List<Task> tasks = new List<Task>();
                tasks.add(new Task());
                return tasks;
            } else if(stubbedMethodName == 'getCompletedTasks'){
                return new List<Task>();
            } else if(stubbedMethodName == 'ignoreTask'){
                return null;
            } else if(stubbedMethodName == 'completeTask'){
                return null;
            }
            return null;
        }
    }

    public class PatientDelegateServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getDelegatedUsersIds'){
                return new List<Id>();
            }
            return null;
        }
    }

    public class ParticipantServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getState'){
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @IsTest
    static void getInitData() {
        TaskService.setMock(new TaskServiceMock());
        PatientDelegateService.setMock(new PatientDelegateServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        Task task = new Task();
        insert task;
        TasksRemote.getPreviewTasks();
        TasksRemote.getParticipantTasks();
    }
}