/**
 * Created by Leonid Bartenev
 */

@IsTest
public class Test_PatientDelegateService {
    
    // Define mocks: ---------------------------------------------------------------------------------------------------
    
    public class DatabaseServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() > 1) {
                SObjectType sObjectType = (SObjectType) listOfArgs[1];
                if(sObjectType == Patient_Delegate__c.getSObjectType()){
                    return new List<Patient_Delegate__c>();
                }else if(sObjectType == Participant__c.getSObjectType()){
                    return new List<Participant__c>{
                            new Participant__c(
                                    Contact__c = TestDataFactory.getFakeId(Contact.getSObjectType())
                            )
                    };
                }
            }
            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() == 1){
                String queryString = (String)listOfArgs[0];
                if(queryString.contains('FROM User')){
                    return new List<User>{
                            new User(Id = TestDataFactory.getFakeId(User.getSObjectType()))
                    };
                }
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
    
    
    // Tests: ----------------------------------------------------------------------------------------------------------
    
    @IsTest
    static void patientDelegateServiceTestTest() {
        DatabaseService.setMock(new DatabaseServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        Test.startTest();
        PatientDelegateService.getInstance().getDelegates();
        PatientDelegateService.getInstance().getParticipant();
        PatientDelegateService.getInstance().isDelegate();
        PatientDelegateService.getInstance().getParticipantUserId();
        PatientDelegateService.getInstance().getDelegatedUsersIds();
        PatientDelegateService.getInstance().getDelegatedContactIds();
        PatientDelegateService.getInstance().getPDelegates();
        PatientDelegateService.getInstance().getDelegateContacts(TestDataFactory.getFakeId(Participant__c.getSObjectType()));
        PatientDelegateService.getInstance().getDelegatedContactIds(TestDataFactory.getFakeId(Participant__c.getSObjectType()));
        PatientDelegateService.getInstance().getPDelegates(TestDataFactory.getFakeId(Participant__c.getSObjectType()));
        Test.stopTest();
    }


}