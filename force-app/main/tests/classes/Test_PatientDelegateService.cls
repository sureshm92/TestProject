/**
 * Created by Leonid Bartenev
 */

@IsTest
public class Test_PatientDelegateService {

    // Define test objects: --------------------------------------------------------------------------------------------

    private static Account accountPartic;

    private static Contact firstParticipantContact;
    private static Contact secondParticipantContact;
    private static Contact firstDelegateContact;
    private static Contact secondDelegateContact;

    private static Participant__c firstParticipant;
    private static Participant__c secondParticipant;

    private static Patient_Delegate__c patientDelegate;

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
                            firstParticipant
                    };
                } else if (sObjectType == Account.getSObjectType()) {
                    return new List<Account>{
                            accountPartic
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
            if (stubbedMethodName == 'getContactById') {
                return firstParticipantContact;
            }
            if (stubbedMethodName == 'getUserContactImpl') {
                return firstParticipantContact;
            }
            return null;
        }
    }

    class PatientDelegateServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs
        ) {
            switch on stubbedMethodName {
                when 'getParticipant' {
                    return firstParticipant;
                }
                when 'getDelegateContact' {
                    return firstDelegateContact;
                }
                when 'getDelegatedContactIds' {
                    return new List<Id>{firstDelegateContact.Id};
                }
                when 'resetDelegate' {
                    Id contactId = firstDelegateContact.Id;
                    Contact delegateContact = new Contact(
                            Id = contactId,
                            userCommunityMode__c = null
                    );
                    update delegateContact;

                    List<Patient_Delegate__c> patientDelegate = [
                            SELECT Id
                            FROM Patient_Delegate__c
                            WHERE Contact__c =: contactId
                    ];
                    delete patientDelegate;
                }
            }
            return null;
        }
    }
    // Tests: ----------------------------------------------------------------------------------------------------------

    @IsTest
    static void patientDelegateServiceTest() {
        refreshTestData();
        DatabaseService.setMock(new DatabaseServiceMock());
        PatientDelegateService.setMock(new PatientDelegateServiceMock());
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
        PatientDelegateService.getDelegateContacts(firstParticipantContact.Id);
        PatientDelegateService.getDelegatedContactIds(firstParticipantContact.Id);

        Test.stopTest();
    }

    /* Used full test instead: Test_MyTeamRemote.testCreatePatientDelegate()
    @IsTest
    static void createPatientDelegateTest() {
        refreshTestData();

        DatabaseService.setMock(new DatabaseServiceMock());
        CommunityService.setMock(new CommunityServiceMock());

        Test.startTest();
        PatientDelegateService.getInstance().createPatientDelegate(secondDelegateContact);
        Test.stopTest();

        List<Patient_Delegate__c> patDel = [
                SELECT Contact__r.FirstName,
                        Participant__c
                FROM Patient_Delegate__c
                WHERE Contact__c = :secondDelegateContact.Id
        ];

        System.assertEquals(1, patDel.size());
        System.assertEquals(secondDelegateContact.FirstName, patDel.get(0).Contact__r.FirstName);
    }*/

    @IsTest
    static void resetDelegateTest() {

        TestData.loadTestData();
        TestData testData = new TestData();

        Contact delegateContact = new Contact(
                FirstName = 'Joseph',
                LastName = 'Davis',
                Email = 'jdavis@somemail.com'
        );
        upsert delegateContact;

        //Patient_Delegates:
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = delegateContact.Id,
                Contact__r = delegateContact,
                Participant__c = testData.participant.Id,
                Participant__r = testData.participant
        );
        upsert patientDelegate;

        System.runAs(testData.participantUser){
            Test.startTest();
            PatientDelegateService.getInstance().resetDelegate(delegateContact.Id, false);
            Test.stopTest();
        }

        Contact contactFromDB = [
                SELECT userCommunityMode__c, userCommunytyType__c
                FROM Contact
                WHERE Id = :delegateContact.Id
        ].get(0);
        System.assertEquals(null, contactFromDB.userCommunityMode__c);
        System.assertEquals(null, contactFromDB.userCommunytyType__c);

        List<Patient_Delegate__c> testRemove = [SELECT Id FROM Patient_Delegate__c WHERE Id = :patientDelegate.Id];
        System.assertEquals(true, testRemove.isEmpty());
    }

    private static void refreshTestData() {
        //Accounts:
        accountPartic = new Account(
                Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME
        );
        upsert accountPartic;

        //Contacts:
        firstParticipantContact = new Contact(
                FirstName = 'Richard',
                LastName = 'Wilson',
                Email = 'r.wilson@gmail.com',
                userCommunityMode__c = 'Participant'
        );
        upsert firstParticipantContact;

        secondParticipantContact = new Contact(
                FirstName = 'David',
                LastName = 'Wilson',
                Email = 'd.wilson@gmail.com',
                userCommunityMode__c = 'Participant'
        );
        upsert secondParticipantContact;

        firstDelegateContact = new Contact(
                FirstName = 'Joseph',
                LastName = 'Davis',
                Email = 'jdavis@somemail.com'
        );
        upsert firstDelegateContact;

        secondDelegateContact = new Contact(
                FirstName = 'Tony',
                LastName = 'Davis',
                Email = 'tdavis@somemail.com'
        );
        upsert secondDelegateContact;

        //Participants:
        firstParticipant = new Participant__c(
                Contact__c = firstParticipantContact.Id
        );
        upsert firstParticipant;

        secondParticipant = new Participant__c(
                Contact__c = secondParticipantContact.Id
        );
        upsert secondParticipant;

        //Patient_Delegates:
        patientDelegate = new Patient_Delegate__c(
                Contact__c = firstDelegateContact.Id,
                Contact__r = firstDelegateContact,
                Participant__c = firstParticipant.Id,
                Participant__r = firstParticipant
        );
        upsert patientDelegate;
    }
}