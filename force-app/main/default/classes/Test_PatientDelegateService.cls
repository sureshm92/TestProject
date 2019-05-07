/**
 * Created by Leonid Bartenev
 */

@IsTest
public class Test_PatientDelegateService {

    // Define test objects: --------------------------------------------------------------------------------------------

    private static Contact participantContact = new Contact(
            Id = TestDataFactory.getFakeId(Contact.getSObjectType()),
            FirstName = 'Richard',
            LastName = 'Wilson',
            Email = 'r.wilson@gmail.com',
            userCommunityMode__c = 'Participant'
    );

    private static Participant__c participant = new Participant__c(
            Id = TestDataFactory.getFakeId(Participant__c.getSObjectType()),
            Contact__c = participantContact.Id,
            Contact__r = participantContact
    );

    private static Contact delegateContact = new Contact(
            Id = TestDataFactory.getFakeId(Contact.getSObjectType()),
            FirstName = 'Joseph',
            LastName = 'Davis',
            Email = 'jdavis@somemail.com'
    );

    private static Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Id = TestDataFactory.getFakeId(Patient_Delegate__c.getSObjectType()),
            Contact__c = delegateContact.Id,
            Contact__r = delegateContact,
            Participant__c = participant.Id,
            Participant__r = participant
    );

    // Define mocks: ---------------------------------------------------------------------------------------------------

    public class DatabaseServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {

            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() > 1) {
                SObjectType sObjectType = (SObjectType) listOfArgs[1];
                if (sObjectType == Patient_Delegate__c.getSObjectType()) {
                    return new List<Patient_Delegate__c>{
                            patientDelegate
                    };
                } else if (sObjectType == Participant__c.getSObjectType()) {
                    return new List<Participant__c>{
                            participant
                    };
                }
            }
            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() == 1) {
                String queryString = (String) listOfArgs[0];
                if (queryString.contains('FROM User')) {
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
            if(stubbedMethodName == 'getContactById') {
                return participantContact;
            }
            if(stubbedMethodName == 'getUserContactImpl') {
                return participantContact;
            }
            return null;
        }
    }


    // Tests: ----------------------------------------------------------------------------------------------------------

    @IsTest
    static void patientDelegateServiceTest() {
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
        PatientDelegateService.getInstance().getDelegateContact(patientDelegate.Contact__c);
        PatientDelegateService.getInstance().getDelegateContacts(participantContact.Id);
        PatientDelegateService.getInstance().getDelegatedContactIds(participantContact.Id);

        Test.stopTest();
    }

//    @IsTest
//    static void createPatientDelegateTest() {
//        DatabaseService.setMock(new DatabaseServiceMock());
//        CommunityService.setMock(new CommunityServiceMock());
//
//        Contact testDelContact = new Contact(
//                Id = TestDataFactory.getFakeId(Contact.getSObjectType()),
//                FirstName = 'Delegat',
//                LastName = 'Test',
//                Email = 'delete@somemail.com'
//        );
//
//        Test.startTest();
//        PatientDelegateService.getInstance().createPatientDelegate(testDelContact);
//        Test.stopTest();
//
//        List<Patient_Delegate__c> patDel = (List<Patient_Delegate__c>) DatabaseService.query(
//                new List<String>{
//                        'Contact__c',
//                        'Participant__c'
//                },
//                Patient_Delegate__c.getSObjectType(),
//                DatabaseService.fieldEqual('Contact__c', testDelContact.Id)
//        );
//        System.assertEquals(1, patDel.size());
//        System.assertEquals(testDelContact.FirstName, patDel.get(0).Contact__r.FirstName);
//    }

    @IsTest
    static void resetDelegateTest() {
        DatabaseService.setMock(new DatabaseServiceMock());
        CommunityService.setMock(new CommunityServiceMock());

        Contact testDelContact = new Contact(
                FirstName = 'Delegat',
                LastName = 'Test',
                Email = 'delete@somemail.com'
        );
        insert testDelContact;

        Patient_Delegate__c testPD = new Patient_Delegate__c(
                Contact__c = testDelContact.Id,
                Participant__c = 'a0G0v0000002Ol5EAE'
        );
        insert testPD;

        Test.startTest();
        PatientDelegateService.getInstance().resetDelegate(testDelContact.Id);
        Test.stopTest();

        Contact contactFromDB = [
                SELECT userCommunityMode__c, userCommunytyType__c
                FROM Contact
                WHERE Id = :testDelContact.Id
        ].get(0);
        System.assertEquals(null, contactFromDB.userCommunityMode__c);
        System.assertEquals(null, contactFromDB.userCommunytyType__c);

        List<Patient_Delegate__c> testRemove = [SELECT Id FROM Patient_Delegate__c WHERE Id = :testPD.Id];
        System.assertEquals(true, testRemove.isEmpty());
    }
}