/**
 * Created by Denis on 12.04.2019.
 */

@IsTest
private class  Test_TaskEditRemote {

    public class PatientDelegateServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getDelegates') {
                return new List<Contact>();
            } else if(stubbedMethodName == 'getParticipantUserId'){
                return TestDataFactory.getFakeId(User.getSObjectType());
            } else if(stubbedMethodName == 'getParticipant'){
                return new Participant__c();
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

    public class CommunityServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getCurrentContactId') {
                return TestDataFactory.getFakeId(Contact.getSObjectType());
            }
            return null;
        }
    }

    @IsTest
    static void getInitTaskEditDataWrapper() {
        PatientDelegateService.setMock(new PatientDelegateServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        TaskEditRemote.TaskEditDataWrapper wrapper = new TaskEditRemote.TaskEditDataWrapper();
    }

}