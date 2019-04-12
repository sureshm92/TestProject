/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_PSEService {
    
    public class DatabaseServiceMock implements System.StubProvider {
        
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'query') {
                return new List<Participant_Study_Enrollment__c>();
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
    
    public class PatientDelegateServiceMock implements System.StubProvider {
        
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'isDelegate') {
                return false;
            }
            return null;
        }
    }
    
    @IsTest
    static void getPSEListForCurrentParticipantTest() {
        DatabaseService.setMock(new DatabaseServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        PatientDelegateService.setMock(new PatientDelegateServiceMock());
        PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_PARTICIPANT, null);
        //PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_HCP, null);
        //PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_PI, null);
        PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_PARTICIPANT, null);
        PSEService.getInstance().getPSEListWithCustomFields(CommunityService.USER_MODE_PARTICIPANT, new List<String>{'Name'}, null);
        PSEService.getInstance().getPSEListForCurrentParticipant();
    }
}