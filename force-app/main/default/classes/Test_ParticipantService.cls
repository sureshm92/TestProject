/**
 * Created by Leonid Bartenev
 */

@IsTest
public class Test_ParticipantService {
    
    public class ParticipantEnrollmentServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getPEnrolmentsCommonCustomFieldsImpl') {
                return new List<Participant_Enrollment__c>{
                        new Participant_Enrollment__c(
                                Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
                        )
                };
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
    
    public class CommunityServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getCurrentContactId') {
                return TestDataFactory.getFakeId(Contact.getSObjectType());
            }
            return null;
        }
    }
    
    public class PSEServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getPSEListForCurrentParticipant') {
                return new List<Participant_Study_Enrollment__c>{
                        new Participant_Study_Enrollment__c()
                };
            }
            return null;
        }
    }
    
    @IsTest
    static void participantServiceTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        PSEService.setMock(new PSEServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        
        // Test logic
        Test.startTest();
        ParticipantService.getParticipantState();
        Test.stopTest();
    }

}