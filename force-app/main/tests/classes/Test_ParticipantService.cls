/**
 * Created by Leonid Bartenev
 */

@IsTest
public class Test_ParticipantService {

    public class ParticipantEnrollmentServiceMock implements StubProvider {

        String participant_Status;

        public ParticipantEnrollmentServiceMock() {
        }

        public ParticipantEnrollmentServiceMock(String participant_Status) {
            this.participant_Status = participant_Status;
        }

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getPEnrolmentsCommonCustomFieldsImpl') {
                return new List<Participant_Enrollment__c>{
                        getPE(participant_Status)
                };
            }
            return null;
        }
    }

    public class PatientDelegateServiceMock implements StubProvider {
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
            if (stubbedMethodName == 'getUserContactImpl') {
                String c = '{"attributes":{"type":"Contact"},"FirstName":"TestF","LastName":"TestL","Name":"TestF TestL"}';
                return (Contact) JSON.deserialize(c, Contact.class);
            }
            return null;
        }
    }

    public class DatabaseServiceMock implements StubProvider {
        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'insertSObjImpl') {
                return (Database.SaveResult)
                        JSON.deserialize('{"id":"0030v00000Dcyq3AAB","success":true,"errors":[]}', Database.SaveResult.class);
            }
            if (stubbedMethodName == 'upsertToDB') {
            }
            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() > 1) {
                SObjectType sObjectType = (SObjectType) listOfArgs[1];
                if (sObjectType == Visit__c.getSObjectType()) {
                    return new Visit__c(Name = 'TestVisit', Visit_Schedule__c = 'Week 1', Icons__c = '');
                } else if (SObjectType == Account.getSObjectType()) {
                    return new List<Account>{
                            new Account(Id = TestDataFactory.getFakeId(Account.getSObjectType()))
                    };
                }
            }
            return null;
        }
    }
    public class ParticipantServiceMock implements System.StubProvider {

        public Object handleMethodCall(Object stubbedObject, String stubbedMethodName, Type returnType,
                List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            if (stubbedMethodName == 'getState') {
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @IsTest
    static void participantServiceTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        // Test logic
        Test.startTest();
        ParticipantService.getParticipantState();
        ParticipantService.getInstance().getState();
        try {
            ParticipantService.getParticipantFullName(getPE(null).Participant__r.Contact__c);
        } catch (ParticipantService.ParticipantServiceException e) {}
        Test.stopTest();
    }

    @IsTest
    static void participantServiceGROUP_FAILEDTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock(PEStatusState.PE_STATUS_ENROLLMENT_FAILED));
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        // Test logic
        Test.startTest();
        ParticipantService.getInstance().getState();
        Test.stopTest();
    }

    @IsTest
    static void participantServiceENROLLMENT_SUCCESSTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock(PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS));
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        // Test logic
        Test.startTest();
        ParticipantService.getInstance().getState();
        Test.stopTest();
    }

    @IsTest
    static void showTermsTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        Test.startTest();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        Boolean showTerms = participantState.showTerms;
        Test.stopTest();

        System.assertEquals(false, showTerms);
    }

    @IsTest
    static void showVisitsTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        Test.startTest();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance().getState();
        participantState.ctp = getPE(null).Clinical_Trial_Profile__r;
        Boolean isShow = participantState.showVisits;
        Test.stopTest();

        System.assertEquals(false, isShow);
    }

    @IsTest
    static void createParticipantAndUpdatePEImplTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        DatabaseService.setMock(new DatabaseServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        String language = 'ru';
        Test.startTest();
        ParticipantService.createParticipantAndUpdatePE(getParticipant(), getParticipantDelegate(), getPE(null), language);
        Test.stopTest();
    }

    @IsTest
    static void getGenderLVListTest() {
        List<LabelValueItem> genderLVList = ParticipantService.getGenderLVList();
        System.assertEquals(2, genderLVList.size());
        System.assertEquals(Label.Gender_Male, genderLVList.get(0).label);
        System.assertEquals('Female', genderLVList.get(1).value);
    }

    @IsTest
    static void isParticipantsAgeOfMajorityTest() {
        System.debug(JSON.serializePretty(ParticipantService.checkParticipantsAgeOfMajority(new List<Participant__c>{new Participant__c(
                Last_Name__c = 'Participant',
                Date_of_Birth__c = '2002-03-10',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'MS',
                Adult__c = true
        ),
                new Participant__c(
                Last_Name__c = 'Participant',
                Date_of_Birth__c = '2000-03-10',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'AL',
                Adult__c = false
                )
        })));
    }

    //Mock data: -------------------------------------------------------------------------------------------------------
    static Participant_Enrollment__c getPE(String partStatus) {
        if (partStatus == null) partStatus = PEStatusState.PE_STATUS_REFERRAL_DECLINED;

        Terms_And_Conditions__c tc = new Terms_And_Conditions__c(Active__c = false);

        Clinical_Trial_Profile__c trial = new Clinical_Trial_Profile__c(
                Id = TestDataFactory.getFakeId(Clinical_Trial_Profile__c.getSObjectType()),
                Protocol_ID__c = 'Prot-333',
                NCT_Number__c = 'NCT02804789',
                Therapeutic_Area__r = new Therapeutic_Area__c(Name = 'Test Area'),
                Patient_Portal_Enabled__c = true,
                Terms_And_Conditions_ID__r = tc,
                Visit_Plan__c = TestDataFactory.getFakeId(Visit_Plan__c.getSObjectType())
        );

        Contact patientContact = new Contact(
                FirstName = 'Richard',
                LastName = 'Wilson',
                Email = 'r.wilson@gmail.com',
                userCommunityMode__c = 'Participant'
        );

        Participant__c participant = new Participant__c(
                Id = TestDataFactory.getFakeId(Participant__c.getSObjectType()),
                First_Name__c = patientContact.FirstName,
                Contact__r = patientContact
        );

        Contact pi = new Contact(
                FirstName = 'Joseph',
                LastName = 'Davis PI And HCP',
                Email = 'jdavis@somemail.com'
        );

        Study_Site__c studySite = new Study_Site__c(
                Name = 'Test SS1',
                Clinical_Trial_Profile__c = trial.Id,
                Clinical_Trial_Profile__r = trial,
                Site__r = new Account(Name = 'Clinic'),
                Principal_Investigator__r = pi,
                Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
                Study_Site_Key__c = '12132123132313',
                Study_Site_Phone__c = '+1(232) 222-3434'
        );

        return new Participant_Enrollment__c(
                Participant_Status__c = partStatus,
                Participant__c = participant.Id,
                Participant__r = participant,
                Clinical_Trial_Profile__c = trial.Id,
                Clinical_Trial_Profile__r = trial,
                Study_Site__r = studySite,
                Study_Site__c = TestDataFactory.getFakeId(Study_Site__c.getSObjectType())
        );
    }

    static Participant__c getParticipant() {
        Contact patientContact = new Contact(
                FirstName = 'Ashly',
                LastName = 'Doyle',
                Email = 'a.doyle@gmail.com',
                userCommunityMode__c = 'Participant'
        );

        return new Participant__c(
                First_Name__c = patientContact.FirstName
        );
    }

    static Participant__c getParticipantDelegate() {
        Contact patientContact = new Contact(
                FirstName = 'Ashly',
                LastName = 'DoyleDelegate',
                Email = 'a.doyledelegate@gmail.com',
                userCommunityMode__c = 'Participant'
        );

        return new Participant__c(
                First_Name__c = patientContact.FirstName
        );
    }

}