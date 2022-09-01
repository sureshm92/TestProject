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

        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getPEnrolmentsCommonCustomFieldsImpl') {
                return new List<Participant_Enrollment__c>{ getPE(participant_Status) };
            }
            return null;
        }
    }

    public class PatientDelegateServiceMock implements StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'isDelegate') {
                return false;
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
            if (stubbedMethodName == 'getUserContactImpl') {
                String c = '{"attributes":{"type":"Contact"},"FirstName":"TestF","LastName":"TestL","Name":"TestF TestL"}';
                return (Contact) JSON.deserialize(c, Contact.class);
            }
            return null;
        }
    }

    public class DatabaseServiceMock implements StubProvider {
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'insertSObjImpl') {
                return (Database.SaveResult) JSON.deserialize(
                    '{"id":"0030v00000Dcyq3AAB","success":true,"errors":[]}',
                    Database.SaveResult.class
                );
            }
            if (stubbedMethodName == 'upsertToDB') {
            }
            if (stubbedMethodName == 'queryImpl' && listOfArgs.size() > 1) {
                SObjectType sObjectType = (SObjectType) listOfArgs[1];
                if (sObjectType == Visit__c.getSObjectType()) {
                    return new Visit__c(
                        Name = 'TestVisit',
                        Visit_Schedule__c = 'Week 1',
                        Icons__c = ''
                    );
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
        public Object handleMethodCall(
            Object stubbedObject,
            String stubbedMethodName,
            Type returnType,
            List<Type> listOfParamTypes,
            List<String> listOfParamNames,
            List<Object> listOfArgs
        ) {
            if (stubbedMethodName == 'getState') {
                return new ParticipantService.ParticipantState();
            }
            return null;
        }
    }

    @IsTest
    static void participantServiceTest() {
        TestData.loadTestData();
        TestData td = new TestData();
        String exceptionMessage;
        ParticipantService.ParticipantState participantState;
        ParticipantService.ParticipantState ptState;
        Test.startTest();
        System.runAs(td.participantUser) {
            participantState = ParticipantService.getParticipantState();
            ptState = ParticipantService.getInstance().getState();
        }
        try {
            ParticipantService.getParticipantFullName(getPE(null).Participant__r.Contact__c);
        } catch (ParticipantService.ParticipantServiceException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, participantState.value);
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, ptState.value);
        System.assertEquals('This contact hasn\'t participant!', exceptionMessage);
    }

    @IsTest
    static void participantServiceTest2() {
        TestData.loadTestData();
        TestData td = new TestData();

        td.ctp.Enrolled_Or_Randomized_Consent_Available__c = true;
        byPassTriggersMethod();
        update td.ctp;

        String exceptionMessage;
        ParticipantService.ParticipantState participantState;
        ParticipantService.ParticipantState ptState;
        Test.startTest();
        System.runAs(td.participantUser) {
            participantState = ParticipantService.getParticipantState();
            ptState = ParticipantService.getInstance().getState();
        }
        try {
            ParticipantService.getParticipantFullName(getPE(null).Participant__r.Contact__c);
        } catch (ParticipantService.ParticipantServiceException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, participantState.value);
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, ptState.value);
        System.assertEquals('This contact hasn\'t participant!', exceptionMessage);
    }

    @IsTest
    static void participantServiceTest3() {
        TestData.loadTestData();
        TestData td = new TestData();

        td.ctp.Received_Until_Consent_Is_Available__c = true;
        byPassTriggersMethod();
        update td.ctp;

        String exceptionMessage;
        ParticipantService.ParticipantState participantState;
        ParticipantService.ParticipantState ptState;
        Test.startTest();
        System.runAs(td.participantUser) {
            participantState = ParticipantService.getParticipantState();
            ptState = ParticipantService.getInstance().getState();
        }
        try {
            ParticipantService.getParticipantFullName(getPE(null).Participant__r.Contact__c);
        } catch (ParticipantService.ParticipantServiceException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, participantState.value);
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, ptState.value);
        System.assertEquals('This contact hasn\'t participant!', exceptionMessage);
    }

    @IsTest
    static void participantServiceTest4() {
        TestData.loadTestData();
        TestData td = new TestData();

        td.ctp.Received_Until_Consent_Is_Available__c = true;
        td.ctp.Enrolled_Or_Randomized_Consent_Available__c = true;
        byPassTriggersMethod();
        update td.ctp;

        String exceptionMessage;
        ParticipantService.ParticipantState participantState;
        ParticipantService.ParticipantState ptState;
        Test.startTest();
        System.runAs(td.participantUser) {
            participantState = ParticipantService.getParticipantState();
            ptState = ParticipantService.getInstance().getState();
        }
        try {
            ParticipantService.getParticipantFullName(getPE(null).Participant__r.Contact__c);
        } catch (ParticipantService.ParticipantServiceException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, participantState.value);
        System.assertEquals(ParticipantService.ParticipantStates.REFERRAL, ptState.value);
        System.assertEquals('This contact hasn\'t participant!', exceptionMessage);
    }
    
    @IsTest
    static void participantServiceTest5() {
        TestData.loadTestData();
        TestData td = new TestData();
        
        td.pe.Participant_Status__c = 'Enrollment Success';
        byPassTriggersMethod();
        update td.pe;
        
        String exceptionMessage;
        ParticipantService.ParticipantState participantState;
        ParticipantService.ParticipantState ptState;
        Test.startTest();
        System.runAs(td.participantUser) {
            participantState = ParticipantService.getParticipantState();
            ptState = ParticipantService.getInstance().getState();
        }
        try {
            ParticipantService.getParticipantFullName(getPE(null).Participant__r.Contact__c);
        } catch (ParticipantService.ParticipantServiceException e) {
            exceptionMessage = e.getMessage();
        }
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.PARTICIPANT, participantState.value);
        System.assertEquals(ParticipantService.ParticipantStates.PARTICIPANT, ptState.value);
    }

    @IsTest
    static void participantServiceGROUP_FAILEDTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(
            new ParticipantEnrollmentServiceMock(PEStatusState.PE_STATUS_ENROLLMENT_FAILED)
        );
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        // Test logic
        Test.startTest();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.ALUMNI, participantState.value);
    }

    @IsTest
    static void participantServiceENROLLMENT_SUCCESSTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(
            new ParticipantEnrollmentServiceMock(PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS)
        );
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        // Test logic
        Test.startTest();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();
        Test.stopTest();
        System.assertEquals(ParticipantService.ParticipantStates.ALUMNI, participantState.value);
    }

    @IsTest
    static void showTermsTest() {
        // Set mocks:
        ParticipantEnrollmentService.setMock(new ParticipantEnrollmentServiceMock());
        CommunityService.setMock(new CommunityServiceMock());
        ParticipantService.setMock(new ParticipantServiceMock());
        Test.startTest();
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();
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
        ParticipantService.ParticipantState participantState = ParticipantService.getInstance()
            .getState();
        participantState.ctp = getPE(null).Clinical_Trial_Profile__r;
        Boolean isShow = participantState.showVisits;
        Test.stopTest();

        System.assertEquals(false, isShow);
    }

    @IsTest
    static void createParticipantAndUpdatePEImplTest() {
        TestData.loadTestData();
        TestData td = new TestData();
        String language = 'ru';
        String exceptionMsg;
        Test.startTest();
        System.runAs(td.participantUser) {
            byPassTriggersMethod();
            try {
                ParticipantService.createParticipantAndUpdatePE(
                    getParticipant(),
                    getParticipantDelegate(),
                    getPE(null),
                    language
                );
            } catch (ParticipantService.ParticipantServiceException e) {
                exceptionMsg = e.getMessage();
            }

            try {
                ParticipantService.createParticipantAndUpdatePE(
                    getParticipant(),
                    getParticipantDelegate(),
                    getPE(null),
                    language
                );
            } catch (ParticipantService.ParticipantServiceException e) {
                exceptionMsg = e.getMessage();
            }
        }
        Test.stopTest();
        System.assert(exceptionMsg.contains('Upsert failed'));
    }

    @IsTest
    static void createParticipantAndUpdatePESImplTest() {
        TestData.loadTestData();
        TestData td = new TestData();
        String language = 'ru';
        String exceptionMsg;
        Test.startTest();
        System.runAs(td.participantUser) {
            byPassTriggersMethod();
            try {
                ParticipantService.createParticipantAndUpdatePES(
                    getParticipant(),
                    getParticipantDelegate(),
                    getPE(null),
                    language
                );
            } catch (ParticipantService.ParticipantServiceException e) {
                exceptionMsg = e.getMessage();
            }

            try {
                ParticipantService.createParticipantAndUpdatePES(
                    getParticipant(),
                    getParticipantDelegate(),
                    getPE(null),
                    language
                );
            } catch (ParticipantService.ParticipantServiceException e) {
                exceptionMsg = e.getMessage();
            }
        }
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
    static void getPhoneTypeLVListTest() {
        List<LabelValueItem> phoneTypeLVList = ParticipantService.getPhoneTypeLVList();
        System.assertEquals(3, phoneTypeLVList.size());
        System.assertEquals(Label.Phone_Type_Home, phoneTypeLVList.get(0).label);
        System.assertEquals('Work', phoneTypeLVList.get(1).value);
    }
    
    @IsTest
    static void getYearofBirthListTest() {
        
        try {
            List<LabelValueItem> yearofBirthList = ParticipantService.getYearofBirthList();
            System.assertEquals(3, yearofBirthList.size());
        } catch(Exception ex){}
        
    }
    
    @IsTest
    static void getPrefixListTest() {
        List<LabelValueItem> prefixList = ParticipantService.getPrefixList();
        System.assertEquals(5, prefixList.size());
        System.assertEquals(Label.PP_Prefix_Mr, prefixList.get(0).label);
        System.assertEquals('Ms.', prefixList.get(1).value);
    }
    
    @IsTest
    static void getFormattedTimeTest() {
        String formattedTime = ParticipantService.getFormattedTime();
        System.assert(formattedTime != null);
    }

    @IsTest
    private static void getNearestLogOutNotificationTest() {

        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );

        TestData.loadTestData();
        TestData testData = new TestData();

        Test.startTest();

        Participant_Enrollment__c pe1 = ContactService.getCurrentPE(
            testData.participantUser.ContactId
        );
        pe1.Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
        update pe1;

        System.runAs(testData.participantUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();
        }
        User pdUser = testData.createPatientDelegate();
        System.runAs(pdUser) {
            CommunityFacadeRemote.isFirstLogon();
            CommunityFacadeRemote.acceptTerms();
            CommunityFacadeRemote.getCommunityData();
        }

        ParticipantService.getNearestLogOutNotification(new List<Id>{testData.participantUser.ContactId});
        Test.stopTest(); 
    }

    @IsTest
    static void isParticipantsAgeOfMajorityTest() {
        List<Participant__c> testAdult = ParticipantService.checkParticipantsAgeOfMajority(
            new List<Participant__c>{
                new Participant__c(
                    Last_Name__c = 'Participant',
                    Date_of_Birth__c = '2000-03-10',
                    Mailing_Country_Code__c = 'US',
                    Mailing_State_Code__c = 'AL'
                )
            }
        );
        List<Participant__c> testChild = ParticipantService.checkParticipantsAgeOfMajority(
            new List<Participant__c>{
                new Participant__c(
                    Last_Name__c = 'Participant',
                    Date_of_Birth__c = '2019-03-10',
                    Mailing_Country_Code__c = 'US',
                    Mailing_State_Code__c = 'MS'
                )
            }
        );
        System.assert(testAdult[0].Adult__c);
        System.assert(!testChild[0].Adult__c);
    }

    //Mock data: -------------------------------------------------------------------------------------------------------
    static Participant_Enrollment__c getPE(String partStatus) {
        if (partStatus == null)
            partStatus = PEStatusState.PE_STATUS_REFERRAL_DECLINED;

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
            First_Name__c = patientContact.FirstName,
            Last_Name__c = patientContact.LastName
        );
    }

    static Participant__c getParticipantDelegate() {
        Contact patientContact = new Contact(
            FirstName = 'Ashly',
            LastName = 'DoyleDelegate',
            Email = 'a.doyledelegate@gmail.com',
            userCommunityMode__c = 'Participant'
        );

        return new Participant__c(First_Name__c = patientContact.FirstName);
    }
    
    static void byPassTriggersMethod() {
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.prepareAdditionalFields.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PETriggerHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );        
        TriggerHandlerExecutor.bypassHandler(
            PENotificationTriggerHandler.CreateNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ClinicalTrialProfileTriggerHandler.UpdateClinicalTrialProfile.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreatePeshafterUpdate.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.class
        );
    }
}