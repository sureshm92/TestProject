/**
 * Created by Denis on 12.04.2019.
 */

@IsTest
private class  Test_TaskEditRemote {

    private static Integer i = 0;

    public class PatientDelegateServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getDelegates') {
                return new List<Contact>();
            } else if(stubbedMethodName == 'getParticipantUserId'){
                return UserInfo.getUserId();
            } else if(stubbedMethodName == 'getParticipant'){
                return new Participant__c();
            } else if (stubbedMethodName == 'getDelegatedUsersIds'){
                return new List<Id>();
            }
            return null;
        }
    }

    public class ParticipantServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if(stubbedMethodName == 'getState'){
                Participant_Study_Enrollment__c pse = new Participant_Study_Enrollment__c();
                ParticipantService.ParticipantState state = new ParticipantService.ParticipantState();
                Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c();
                ctp.NCT_Number__c = 'NCT0000000' + i;
                ctp.Protocol_ID__c = 'tt12345677' + i;
                i++;
                insert ctp;
                state.ctp = ctp;
                state.pse = pse;
                return state;
            }
            return null;
        }
    }

    public class CommunityServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getCurrentContactId') {
                return TestDataFactory.getFakeId(Contact.getSObjectType());
            }
            return null;
        }
    }

    public class TaskServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getTask') {
                return new Task();
            }
            return null;
        }
    }

    @IsTest
    static void getInitTaskEditDataWrapper() {
        PatientDelegateService.setMock(new PatientDelegateServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        TaskService.setMock(new TaskServiceMock());
        Task task = new Task();
        task.Subject = 'test';
        task.Task_Type__c = 'Medication';
        task.Reminder_Date__c = Datetime.now();
        insert task;
        TaskEditRemote.TaskEditDataWrapper wrapper = new TaskEditRemote.TaskEditDataWrapper();
        TaskEditRemote.getTaskEditData(task.Id);
        task.Reminder_Date__c = task.Reminder_Date__c.addDays(1);
        TaskEditRemote.upsertTask(task);
        TaskEditRemote.markAsCompleted(task);
        TaskEditRemote.deleteTask(task);
    }

}