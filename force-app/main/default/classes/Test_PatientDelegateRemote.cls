/**
 * Created by Igor Malyuta on 18.04.2019.
 */
@IsTest
public class Test_PatientDelegateRemote {

    /*
    getParticipant
    getDelegateContact
    getDelegatedContactIds
    resetDelegate
    getState().isDelegate
     */
    class PatientDelegateServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            switch on stubbedMethodName {
                when 'getParticipant' {
                    return new Participant__c(Contact__c = TestDataFactory.getFakeId(Contact.getSObjectType()));
                }
                when 'getDelegateContact' {
                    return new Contact(Id = TestDataFactory.getFakeId(Contact.getSObjectType()));
                }
                when 'getDelegatedContactIds' {

                }
            }
            return null;
        }

    }
}