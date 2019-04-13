/**
 * Created by Leonid Bartenev
 */

@IsTest
private class Test_PSEService {
    
    // Define mocks: ---------------------------------------------------------------------------------------------------
    
    public class DatabaseServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'queryImpl') {
                return new List<Participant_Study_Enrollment__c>();
            }
            return null;
        }
    }
    
    public class CommunityServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getCurrentContactId') {
                return TestDataFactory.getFakeId(Contact.getSObjectType());
            }
            return null;
        }
    }
    
    public class DelegateServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getDelegatedHCPEnrollmentIdsImpl') {
                return new List<Id>();
            } else if(stubbedMethodName == 'getDelegatedStudySiteIdsImpl'){
                return new List<Id>();
            }
            return null;
        }
    }
    
    public class PatientDelegateServiceMock implements StubProvider{
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'isDelegate') {
                return false;
            }
            return null;
        }
    }
    
    // Tests: ----------------------------------------------------------------------------------------------------------
    
    @IsTest
    static void getPSEListForCurrentParticipantTest() {
        //Set Mocks:
        DatabaseService.setMock(new DatabaseServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        PatientDelegateService.setMock(new PatientDelegateServiceMock());
        DelegateService.setMock(new DelegateServiceMock());
        
        Test.startTest();
        PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_PARTICIPANT, null);
        PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_HCP, null);
        PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_PI, null);
        PSEService.getInstance().getPSEListCommon(CommunityService.USER_MODE_PARTICIPANT, null);
        PSEService.getInstance().getPSEListWithCustomFields(CommunityService.USER_MODE_PARTICIPANT, new List<String>{'Name'}, null);
        PSEService.getInstance().getPSEListForCurrentParticipant();
        Test.stopTest();
    }
}