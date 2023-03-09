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
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() > 1) {
                SObjectType sObjectType = (SObjectType) listOfArgs[1];
                if (sObjectType == Patient_Delegate__c.getSObjectType()) {
                    return new List<Patient_Delegate__c>{ patientDelegate };
                } else if (sObjectType == Participant__c.getSObjectType()) {
                    return new List<Participant__c>{ firstParticipant };
                } else if (sObjectType == Account.getSObjectType()) {
                    return new List<Account>{ accountPartic };
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
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
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
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            switch on stubbedMethodName {
                when 'getParticipant' {
                    return firstParticipant;
                }
                when 'getDelegateContact' {
                    return firstDelegateContact;
                }
                when 'getDelegatedContactIds' {
                    return new List<Id>{ firstDelegateContact.Id };
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
                        WHERE Contact__c = :contactId
                    ];
                    delete patientDelegate;
                }
            }
            return null;
        }
    }
    // Tests: ----------------------------------------------------------------------------------------------------------

    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void patientDelegateServiceTest() {
        refreshTestData();
        TestData testData = new TestData();
        List<Contact> delegateContacts;
        Participant__c participant;
        Boolean isDelegate;
        Boolean delegateAlreadyExisting;
        Id userId;
        List<Id> delUserIds;
        List<Id> delConIds;
        List<Id> delConIds2;
        List<Patient_Delegate__c> patientDelegates;
        Contact delCon;
        List<Contact> delCons;
        User delegateUser = testData.createPatientDelegate();
        insert delegateUser;
        List<Contact> conDel = [SELECT Id, userCommunityDelegateId__c FROM Contact];
        Test.startTest();
        System.runAs(testData.participantUser) {
            delegateContacts = PatientDelegateService.getInstance().getDelegates();
            participant = PatientDelegateService.getInstance().getParticipant();
            isDelegate = PatientDelegateService.getInstance().isDelegate();
            delegateAlreadyExisting = PatientDelegateService.getInstance()
                .delegateAlreadyExists(conDel[0]);
            userId = PatientDelegateService.getInstance().getParticipantUserId();
            delUserIds = PatientDelegateService.getInstance().getDelegatedUsersIds();
            delConIds = PatientDelegateService.getInstance().getDelegatedContactIds();
            patientDelegates = PatientDelegateService.getInstance().getPDelegates();
            PatientDelegateService.getPDelegates(new list<Id>{participant.contact__c});
            //delCon = PatientDelegateService.getInstance().getDelegateContact(conDel[0].Id);
            delCons = PatientDelegateService.getDelegateContacts(firstParticipantContact.Id);
            delConIds2 = PatientDelegateService.getDelegatedContactIds(firstParticipantContact.Id);
            PatientDelegateService.getDelegatedContactIdsEmailOptIn(firstParticipantContact.Id);
            PatientDelegateService.getParticipantIdsByDelegatedContactIdMap(
                new List<Id>{ firstDelegateContact.Id, secondDelegateContact.Id }
            );
            PatientDelegateService.getPastPEIdsListByContactIdMap(
                new List<Id>{ firstDelegateContact.Id, secondDelegateContact.Id }
            );
            PatientDelegateService.getAvailablePEIdsListByContactIdMap(
                new List<Id>{ firstDelegateContact.Id, secondDelegateContact.Id }
            );
        }
        Test.stopTest();
        System.assertEquals(1, delegateContacts.size());
        System.assertEquals(true, participant != null ? true : false);
        System.assertEquals(true, userId != null ? true : false);
        System.assertEquals(false, isDelegate);
        System.assertEquals(1, delUserIds.size());
        System.assertEquals(1, delConIds.size());
        System.assertEquals(true, patientDelegates != null ? true : false);
        //System.assertEquals(true, delCon != null ? true : false);
        System.assertEquals(1, delCons.size());
        System.assertEquals(true, delConIds2 != null ? true : false);
    }

    // Used full test instead: Test_MyTeamRemote.testCreatePatientDelegate()
    @IsTest
    static void createPatientDelegateTest() {
        refreshTestData();

        DatabaseService.setMock(new DatabaseServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        Test.startTest();
        // PatientDelegateService.getInstance().createPatientDelegate(secondDelegateContact);
        Test.stopTest();

        List<Patient_Delegate__c> patDel = [
            SELECT Contact__r.FirstName, Participant__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :secondDelegateContact.Id
        ];

        // System.assertEquals(1, patDel.size());
        //System.assertEquals(secondDelegateContact.FirstName, patDel.get(0).Contact__r.FirstName);
    }
    
    @IsTest
    static void delegateTestwithContact(){
        TestData testData = new TestData();
        
        Contact delegateContact = new Contact(
            FirstName = 'Joseph',
            LastName = 'Davis',
            Email = 'jdavis@somemail.com'
        );
        upsert delegateContact;
        
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegateContact.Id,
            Contact__r = delegateContact,
            Participant__c = testdata.participant.id,
            Participant__r = testdata.participant
        );
        upsert patientDelegate;
        
        Test.startTest();
        PatientDelegateService.getDelegatedParticipantIds(delegateContact.id);
        PatientDelegateService.getDelegateContactIdsByPAContactIs(new List<ID>{testData.participant.Contact__c});
        PatientDelegateService.getDelegatedCntsByParticipantCnt(new List<ID>{testData.participant.Contact__c},new List<String>{'Name','Email'});
        PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(new List<ID>{testData.participant.Id});
		PatientDelegateService.isPrimaryDelegate(delegateContact.id,testdata.participant.id);
        PatientDelegateService.getPDForMinorOrAdultWithoutEmailPar(delegateContact.id);
        PatientDelegateService.getPerRecords(new set<Id>{testData.pe.id});
        Test.stopTest();
        
    }

    @IsTest
    static void resetDelegateTest() {
        TestData testData = new TestData();
        
        Participant_Enrollment__c per = new Participant_Enrollment__c(id = testData.pe.id);
        per.Participant_Status__c = 'Enrollment Success';
        update per;
        
        Contact delegateContact = new Contact(
            FirstName = 'Joseph',
            LastName = 'Davis',
            Email = 'jdavis@somemail.com'
        );
        upsert delegateContact;
        
    
		 Participant__c p = new Participant__c(
            First_Name__c = 'Joseph',
            Last_Name__c = 'Davis',
            Contact__c = delegateContact.Id
        );
        insert p;
        
        //Patient_Delegates:
        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegateContact.Id,
            Contact__r = delegateContact,
            Participant__c = testdata.participant.id,
            Participant__r = testdata.participant
        );
        upsert patientDelegate;
		
        
        System.runAs(testData.participantUser) {
            Test.startTest();
            PatientDelegateService.getInstance().getParticipant();
            PatientDelegateService.getInstance().isDelegate();
            PatientDelegateService.getInstance().getParticipantUserId();
            PatientDelegateService.getInstance().getPDelegates();
            PatientDelegateService.getInstance().getDelegateContact(delegateContact.Id);
            PatientDelegateService.getInstance().getDelegatedUsersIds();
            PatientDelegateService.getPEIdsListByContactIdMap(
                new List<Id>{ testData.participant.Contact__c },
                '',
                true
            );
            PatientDelegateService.getForExclStatusPEIdsForContact(
                testData.participant.Contact__c,
                PEStatusState.PE_STATUS_GROUP_ACTIVE
            );
            PatientDelegateService.getInstance().resetDelegate(delegateContact.Id, false);
            PatientDelegateService.getInstance().createPatientDelegate(delegateContact,null);
            CommunityService.isUserModeValid('');
            CommunityService.getConvertedStatus('tset \\( ');
            CommunityService.getCommunityProfile();
            CommunityService.ActivateUsers(new Set<id>{ delegateContact.Id });
            CommunityService.isUserInCommunity(delegateContact.Id);
            CommunityService.setUserToCommunity(testData.participantUser);
            CommunityService.isNewSession();
            CommunityService.setUserToCommunity(testData.participantUser.contactid);
            // CommunityService.setUserToCommunity(delegateContact.Id);
            PatientDelegateService pds = new PatientDelegateService();
            pds.createPDAlerts(delegateContact);
            PatientDelegateService.changeStatus(delegateContact.Id, 'Active');
            PatientDelegateService.getParticipantByDelegateContactId(delegateContact.Id);
            PatientDelegateService.getPastPEIdsForContact(delegateContact.Id);
            PatientDelegateService.getAvailablePEIdsForContact(delegateContact.Id);
            
            
            Test.stopTest();
        }

        Contact contactFromDB = [
                SELECT userCommunityMode__c, userCommunytyType__c
                FROM Contact
                WHERE Id = :delegateContact.Id
            ]
            .get(0);
        CommunityService.getUserId();

        //System.assertEquals(null, contactFromDB.userCommunityMode__c);
        System.assertEquals(null, contactFromDB.userCommunytyType__c);

        List<Patient_Delegate__c> testRemove = [
            SELECT Id
            FROM Patient_Delegate__c
            WHERE Id = :patientDelegate.Id
        ];
        System.assertEquals(true, testRemove.isEmpty());
    }

    private static void refreshTestData() {
        //Accounts:
        accountPartic = new Account(Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME);
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
        firstParticipant = new Participant__c(Contact__c = firstParticipantContact.Id);
        upsert firstParticipant;

        secondParticipant = new Participant__c(Contact__c = secondParticipantContact.Id);
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