/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_ParticipantInformationRemote {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }

    @IsTest
    static void getInitData() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> lstPESH = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        pesh.Date__c = Datetime.now();
        pesh.Status__c = 'Eligibility Passed';
        pesh.ParticipantEnrollment__c = testData.pe.Id;
        lstPESH.add(pesh);
        Participant_Enrollment_Status_History__c pesh2 = new Participant_Enrollment_Status_History__c();
        pesh2.Date__c = Datetime.now();
        pesh2.Status__c = 'Participant No Show';
        pesh2.ParticipantEnrollment__c = testData.pe.Id;
        lstPESH.add(pesh2);
        insert lstPESH;

        Study_Site__c objstudy = [SELECT ID FROM Study_Site__c LIMIT 1];

        Test.startTest();
        System.runAs(testData.piUser) {
            ParticipantInformationRemote.getInitData();
            ParticipantInformationRemote.getSteps(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null
            );
            ParticipantInformationRemote.getPrintInformation(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null
            );
            ParticipantInformationRemote.getPrintInfoWithSteps(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null
            );
            ParticipantInformationRemote.checkPILevelI(objstudy.ID);
            // ParticipantInformationRemote.getPESH(testData.pe.id);
        }
        Test.stopTest();
    }

    @isTest
    public static void testPeshRecordforSuccesfulyengaed() {
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> lstPESH = new List<Participant_Enrollment_Status_History__c>();
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        pesh.Date__c = Datetime.now();
        pesh.Status__c = 'Successfully re-engaged';
        pesh.ParticipantEnrollment__c = testData.pe.Id;
        insert pesh;
        Test.startTest();
        System.runAs(testData.piUser) {
            // ParticipantInformationRemote.getPESH(testData.pe.id);
            ParticipantInformationRemote.getPrintInformation(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null
            );
        }

        test.stoptest();
    }

    @IsTest
    static void updateState() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );
            path.steps[path.currentStepInd].outcome = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
            ParticipantInformationRemote.updatePatientInfoAndStatus(
                JSON.serialize(testData.participant),
                JSON.serialize(testData.pe),
                JSON.serialize(path),
                testData.pe.Id
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdatePatientInfo() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );
            ParticipantInformationRemote.updatePatientInfo(
                JSON.serialize(testData.participant),
                JSON.serialize(testData.pe)
            );
            try {
                ParticipantInformationRemote.createUserForPatientProtal(
                    JSON.serialize(testData.pe),
                    true
                );
            } catch (Exception e) {
                System.debug('Exception');
            }
            ParticipantInformationRemote.getParticipantDelegates(
                JSON.serialize(testData.participant.Id)
            );
            ParticipantInformationRemote.updateUserLanguage(
                JSON.serialize(testData.participantUser)
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void testUpdateParticipant() {
        TestData testData = new TestData();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test011@mail.ru';
        participant.First_Name__c = 'testName1';
        participant.Last_Name__c = 'testLastName1';
        participant.Date_of_Birth__c = '2000-04-18';
        insert participant;
        Test.startTest();
        System.runAs(testData.piUser) {
            AddPatientByPIRemote.updateParticipant(JSON.serialize(participant));
        }
        Test.stopTest();
    }
    @IsTest
    static void testCreateParticipantDelegate() {
        ClassFactory.clearStubTypesByClassNamesMap();
        ClassFactory.putStubTypeByClassName(
            CommunityService.class,
            StubBuilder.newInstance(CommunityService.class)
                .when('createPortalUsers')
                .then(null)
                .when('createParticipantUsers')
                .then(null)
                .build()
        );
        TestData testData = new TestData();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant;

        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';

        Participant__c participantDel1 = new Participant__c();
        participantDel1.Email__c = 'Test0198@mail.ru';
        participantDel1.First_Name__c = 'testName1';
        participantDel1.Last_Name__c = 'testLastName1';
        participantDel1.Phone__c = '14124189';

        participantDel1.Birth_Year__c = '1990';

        Contact objCon = new Contact();
        objCon.Participant_Phone_Opt_In_Permit_Phone__c = true;
        objCon.Participant_Opt_In_Status_Emails__c = true;
        objCon.Participant_Opt_In_Status_SMS__c = true;
        Test.startTest();
        System.runAs(testData.piUser) {
            try {
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel),
                    null,
                    participant.Id,
                    JSON.serialize(participant),
                    true,
                    null,
                    JSON.serialize(objCon),
                    true,
                    false,
                    null
                );
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel1),
                    null,
                    participant.Id,
                    JSON.serialize(participant),
                    true,
                    null,
                    JSON.serialize(objCon),
                    true,
                    false,
                    null
                );
                ParticipantInformationRemote.getDelegates(String.valueOf(participant.Id));
            } catch (exception e) {
                system.debug('teste');
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void updateStateCC() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );
            path.steps[path.currentStepInd].outcome = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
            ParticipantInformationRemote.updatePatientStatusCC(
                JSON.serialize(path),
                testData.pe.Id,
                false,
                false,
                null,
                false,
                false
            );
        }
        Test.stopTest();
    }

    @isTest
    static void updateNotesTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );
            path.steps[path.currentStepInd].notes = 'note';
            ParticipantInformationRemote.updatePatientStatusCC(
                JSON.serialize(path),
                testData.pe.Id,
                false,
                true,
                null,
                false,
                false
            );
            ParticipantInformationRemote.updatePatientStatus(
                JSON.serialize(path),
                testData.pe.Id,
                false,
                true,
                null,
                false,
                false
            );
            // ParticipantInformationRemote.updatePatientStatusHelper(JSON.serialize(testData.pe),JSON.serialize(path),true,true,null,true,true);
            path.steps[path.currentStepInd + 1].state = 'neutral';
            path.steps[path.currentStepInd + 1].title = 'Inital Visit';
            ParticipantInformationRemote.updateNotes(path, testData.pe, null, false);
            ParticipantInformationRemote.updateWithDividerWithNotes(path, testData.pe, null);
        }
        Test.stopTest();
    }

    @isTest
    static void updateNotesupdatePatientStatusHelper() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );
            path.steps[path.currentStepInd].notes = 'note';

            ParticipantInformationRemote.updatePatientStatusHelper(
                JSON.serialize(testData.pe),
                JSON.serialize(path),
                false,
                true,
                null,
                false,
                false
            );
            path.steps[path.currentStepInd + 1].state = 'neutral';
            path.steps[path.currentStepInd + 1].title = 'Inital Visit';
            // ParticipantInformationRemote.updateNotes(path, testData.pe, null, false);
            //  ParticipantInformationRemote.updateWithDividerWithNotes(path, testData.pe, null);
        }
        Test.stopTest();
    }

    @isTest
    static void testcheckDuplicatePDelegates() {
        TestData testData = new TestData();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant;
        ParticipantInformationRemote.checkDuplicatePDelegates(
            participant.Id,
            participant.Email__c,
            participant.First_Name__c,
            participant.Last_Name__c
        );
    }
    @isTest
    static void testupdateParticipantData() {
        TestData testData = new TestData();
        ParticipantInformationRemote.updateParticipantData(testData.pe.Id);
    }

    @isTest
    static void testupdateParticipantContactLanguage() {
        TestData testData = new TestData();
        ParticipantInformationRemote.updateParticipantContactLanguage(
            JSON.serialize(testData.piContact)
        );
    }

    @isTest
    static void testgetMedicalHistory() {
        TestData testData = new TestData();
        ParticipantInformationRemote.getMedicalHistory(testData.pe.Id);
    }

    @isTest
    static void testcheckDelegateDuplicate() {
        TestData testData = new TestData();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant;
        ParticipantInformationRemote.checkDelegateDuplicate(
            participant.Email__c,
            participant.First_Name__c,
            participant.Last_Name__c,
            participant.Id
        );
    }

    @isTest
    static void testconnectDelegateToPatient() {
        TestData testData = new TestData();
        Account a = new Account(name = 'Test');
        insert a;
        Clinical_Trial_Profile__c ctp = testData.ctp;
        Study_Site__c st = new Study_Site__c(
            Name = 'Test Site',
            Site__c = a.id,
            Clinical_Trial_Profile__c = ctp.Id,
            Principal_Investigator__c = testData.piContact.Id,
            Study_Site_Key__c = 'AEWR5436'
        );
        insert st;

        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant;

        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        insert participantDel;

        Participant__c participantDel1 = new Participant__c();
        participantDel1.Email__c = 'Test01@mail.ru';
        participantDel1.First_Name__c = 'testName';
        participantDel1.Last_Name__c = 'testLastName';
        participantDel1.Phone__c = '141241';
        participantDel1.Phone_Type__c = 'Home';
        insert participantDel1;

        /*
        Participant__c participant2 = new Participant__c();
        participant.Email__c = 'Test02@mail.ru';
        participant.First_Name__c = 'testName2';
        participant.Last_Name__c = 'testLastName2';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant2;
        
        Participant__c participantDel2 = new Participant__c();
        participantDel.Email__c = 'Test02@mail.ru';
        participantDel.First_Name__c = 'testName2';
        participantDel.Last_Name__c = 'testLastName2';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        
        Participant__c participantDel3 = new Participant__c();
        participantDel1.Email__c = 'Test02@mail.ru';
        participantDel1.First_Name__c = 'testName2';
        participantDel1.Last_Name__c = 'testLastName2';
        participantDel1.Phone__c = '141241';
        participantDel1.Phone_Type__c = 'Home';
        */
        ParticipantInformationRemote.connectDelegateToPatient(
            JSON.serialize(participant),
            JSON.serialize(participantDel),
            st.id,
            true,
            JSON.serialize(participantDel1),
            true
        );
        //ParticipantInformationRemote.checkPILevelI(st.id);

        /*
        ParticipantInformationRemote.connectDelegateToPatient(JSON.serialize(participant2),
                                                             JSON.serialize(participantDel2),
                                                             st.id,
                                                             false,
                                                             JSON.serialize(participantDel3),
                                                             true);
        */
        //ParticipantInformationRemote.checkPILevelI(st.id);
    }

    @isTest
    static void testupdatePatientInfoAndStatusWithDelegateCC() {
        TestData testData = new TestData();

        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );

            ParticipantInformationRemote.updatePatientInfoAndStatusWithDelegateCC(
                JSON.serialize(testData.participant),
                JSON.serialize(testData.pe),
                JSON.serialize(path),
                testData.pe.id,
                JSON.serialize(participantDel),
                null,
                true,
                true,
                'test',
                JSON.serialize(testData.piContact)
            );
            ParticipantInformationRemote.checkNeedsGuardian(JSON.serialize(testData.participant));
            ParticipantInformationRemote.checkDelegateAge(
                JSON.serialize(testData.participant),
                JSON.serialize(participantDel)
            );
            ParticipantInformationRemote.updatePatientStatusCCHelper(
                JSON.serialize(testData.pe),
                JSON.serialize(path),
                true,
                true,
                PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
                false
            );
            ParticipantInformationRemote.getUser(testData.piContact.Id);
        }
    }

    @isTest
    static void testcheckExisitingParticipant() {
        TestData testData = new TestData();
        test.starttest();
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = new Contact(
            LastName = 'LastnameCheck',
            FirstName = 'FirstnameCheck',
            Phone_Type__c = 'Home',
            email = 'Test01@mail.ru',
            Phone = '9876543211',
            AccountId = a.id
        );

        insert cn;

        ParticipantInformationRemote.checkExisitingParticipant(
            'FirstnameCheck',
            'LastnameCheck',
            'Test01@mail.ru',
            testData.participant.id
        );
        test.stoptest();
    }

    @isTest
    static void testcheckExisitingParticipant1() {
        TestData testData = new TestData();
        test.starttest();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'testuserCheck@gmail.comm';
        participant.First_Name__c = 'testNamecheck';
        participant.Last_Name__c = 'testUserNamecheck';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';

        insert participant;
        ParticipantInformationRemote.checkExisitingParticipant(
            'testNamecheck',
            'testUserNamecheck',
            'testuserCheck@gmail.comm',
            testData.participant.id
        );
        test.stoptest();
    }

    @isTest
    static void testgetPESHrecord() {
        TestData testData = new TestData();
        Participant_Enrollment__c pe = testData.pe;
        pe.Participant_Status__c = 'Eligibility Passed';
        update pe;
        ParticipantInformationRemote.getPESHrecord(testData.pe.id);
    }

    @isTest
    static void testupdateParticipantAndDelegates() {
        TestData testData = new TestData();
        integer i = integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = new Contact(
            LastName = 'testUser' + i,
            FirstName = 'testName' + i,
            Phone_Type__c = 'Home',
            email = 'testuser' + i + '@cc.vv',
            AccountId = a.id
        );

        insert cn;

        Participant__c participant = new Participant__c();
        participant.Email__c = 'testuser' + i + '@cc.vv';
        participant.First_Name__c = 'testName' + i;
        participant.Last_Name__c = 'testUser' + i;
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        participantDel.Contact__c = cn.id;
        insert participantDel;
        List<Participant__c> pdList = new List<Participant__c>();
        pdList.add(participantDel);

        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = testData.participant.id,
            Status__c = 'Active',
            Contact__c = testData.piContact.id
        );
        insert pd;
        List<String> pList = new List<String>();
        pList.add(pd.id);
        System.runAs(testData.piUser) {
            ParticipantInformationRemote.updateParticipantAndDelegates(
                testData.pe.Id,
                JSON.serialize(testData.participant),
                JSON.serialize(cn),
                JSON.serialize(pdList),
                pList,
                false,
                testData.ss.id
            );

            ParticipantInformationRemote.disconnectDelegateToPatient(pd.Id);
        }
    }

    @isTest
    static void testUpdatePatientInfoWithDelegate() {
        TestData testData = new TestData();
        Account a = new Account(name = 'Test');
        insert a;
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );
            path.steps[path.currentStepInd].outcome = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
            Participant__c participantDel = new Participant__c();
            participantDel.Email__c = 'Test011@mail.ru';
            participantDel.First_Name__c = 'testName1';
            participantDel.Last_Name__c = 'testLastName1';
            participantDel.Date_of_Birth__c = '2000-04-18';
            Contact cn = new Contact(
                LastName = 'testUser' + '1',
                FirstName = 'testName' + '1',
                email = 'testuser' + '1' + '@cc.vv',
                AccountId = a.id
            );
            ParticipantInformationRemote.updatePatientInfoWithDelegate(
                JSON.serialize(testData.participant),
                JSON.serialize(testData.pe),
                JSON.serialize(participantDel),
                '',
                JSON.serialize(cn)
            );
            try {
                ParticipantInformationRemote.updatePatientInfoAndStatusWithDelegate(
                    JSON.serialize(testData.participant),
                    JSON.serialize(testData.pe),
                    JSON.serialize(path),
                    testData.pe.Id,
                    JSON.serialize(participantDel),
                    '',
                    true,
                    true,
                    '',
                    JSON.serialize(cn)
                );
            } catch (exception ex) {
                system.debug('>>>excc>>' + ex.getMessage());
            }
        }
        Test.stopTest();
    }

    @isTest
    static void testUpdatePatientInfoWithDelegate_Existing() {
        TestData testData = new TestData();
        Account a = new Account(name = 'Test');
        insert a;
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');
            Participant_Enrollment__c pe = ParticipantEnrollmentService.getParticipantEnrollment(
                testData.pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                pe
            );
            path.steps[path.currentStepInd].outcome = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
            Participant__c participantDel = new Participant__c();
            participantDel.Email__c = 'Test011@mail.ru';
            participantDel.First_Name__c = 'testName1';
            participantDel.Last_Name__c = 'testLastName1';
            participantDel.Date_of_Birth__c = '2000-04-18';
            participantDel.Birth_Year__c = '2000';
            Contact cn = new Contact(
                LastName = 'testLastName1',
                FirstName = 'testName1',
                email = 'Test011@mail.ru',
                AccountId = a.id
            );
            insert cn;
            Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = cn.Id,
                Contact__r = cn,
                Participant__c = testData.participant.Id,
                Participant__r = testData.participant
            );
            insert patientDelegate;
            ParticipantInformationRemote.updatePatientInfoWithDelegate(
                JSON.serialize(testData.participant),
                JSON.serialize(testData.pe),
                JSON.serialize(participantDel),
                '',
                JSON.serialize(cn)
            );
            ParticipantInformationRemote.disconnectDelegateToPatient(patientDelegate.Id);
        }
        Test.stopTest();
    }

    @isTest
    static void testGetMasked() {
        TestData testData = new TestData();

        Test.startTest();
        System.runAs(testData.piUser) {
            ParticipantInformationRemote.getMasked(true, 'CC', 'Test Name');

            ParticipantInformationRemote.getMasked(true, 'PI', 'Test Name');
        }
        Test.stopTest();
    }
}
