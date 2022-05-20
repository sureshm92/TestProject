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
        }
        Test.stopTest();
    }
    @IsTest
    static void updateState() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add('(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)');
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
            PE_COMMON_FIELDS.add('(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)');
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
            AddPatientByPIRemote.checkNeedsGuardian(JSON.serialize(participant));
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
        Test.startTest();
        System.runAs(testData.piUser){
            try {
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel),
                    null,
                    participant.Id,
                    JSON.serialize(participant),
                    true,
                    null
                );
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel1),
                    null,
                    participant.Id,
                    JSON.serialize(participant),
                    true,
                    null
                );
                ParticipantInformationRemote.getDelegates(String.valueOf(participant.Id));
            }catch(exception e) {system.debug('teste');}}
        Test.stopTest();
    } 

    @IsTest
    static void updateStateCC() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add('(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)');
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
                false
            );
            ParticipantInformationRemote.updatePatientStatusCC(
                JSON.serialize(path),
                testData.pe.Id,
                true,
                false,
                null,
                false
            );
            try {
                ParticipantInformationRemote.updatePatientStatusCC(
                    JSON.serialize('test'),
                    testData.pe.Id,
                    true,
                    false,
                    null,
                    false
                );
            }catch(Exception ex){}
        }
        Test.stopTest();
    }

    @isTest
    static void updateNotesTest() {
        TestData testData = new TestData();
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user'
        );
        insert pehistory1;
       
        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add('(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)');
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
            Map<String, Participant_Workflow_Form_Field__mdt> fieldsMap =ParticipantWorkflowService.getFieldsByObjectFieldNameMap(
                testData.ctp,
                pe
            );
            path.steps[path.currentStepInd].notes = 'note';
            ParticipantInformationRemote.updatePatientStatusCC(
                JSON.serialize(path),
                testData.pe.Id,
                false,
                true,
                null,false
            );
            ParticipantInformationRemote.updatePatientStatus(
                JSON.serialize(path),
                testData.pe.Id,
                false,
                true,
                null,false
            );
            path.steps[path.currentStepInd + 1].state = 'neutral';
            path.steps[path.currentStepInd + 1].title = 'Inital Visit';
            ParticipantInformationRemote.updateNotes(path, testData.pe, null, false);
            ParticipantInformationRemote.updateWithDividerWithNotes(path, testData.pe, null);

            Participant_Enrollment_Status_History__c pehistory2 = new Participant_Enrollment_Status_History__c(
                Date__c = Datetime.now(),
                Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
                Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
                ParticipantEnrollment__c = testData.pe.Id,
                Non_Enrollment_Reason__c= 'PI Decision',
                Notes__c='Test Notes testing testclass code on this date by test user'
            );
            insert pehistory2;
            path.steps[path.currentStepInd + 1].state = 'in_progress';
            ParticipantInformationRemote.updateWithDividerWithNotes(path, testData.pe, pehistory1.Status__c);
          
        }
        Test.stopTest();
    }
    
    @isTest
    static void testcheckDuplicatePDelegates(){
        TestData testData = new TestData();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant;
        ParticipantInformationRemote.checkDuplicatePDelegates(participant.Id,
                                                              participant.Email__c,
                                                              participant.First_Name__c,
                                                              participant.Last_Name__c);
    }
    @isTest
    static void testupdateParticipantData(){
        TestData testData = new TestData();
        ParticipantInformationRemote.updateParticipantData(testData.pe.Id);
    }
    
    @isTest
    static void testupdateParticipantContactLanguage(){
        TestData testData = new TestData();
        ParticipantInformationRemote.updateParticipantContactLanguage(JSON.serialize(testData.piContact));
        try{
            ParticipantInformationRemote.updateParticipantContactLanguage(JSON.serialize('testData.piContact'));
        }catch(Exception ex){}
        
    }
    
    @isTest
    static void testgetMedicalHistory(){
        TestData testData = new TestData();
        ParticipantInformationRemote.getMedicalHistory(testData.pe.Id);
        
    }
    
    @isTest
    static void testcheckDelegateDuplicate(){
        TestData testData = new TestData();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        insert participant;
        ParticipantInformationRemote.checkDelegateDuplicate(participant.Email__c,
                                                           participant.First_Name__c,
                                                           participant.Last_Name__c,
                                                           participant.Id);
        
    }
    
    @isTest
    static void testconnectDelegateToPatient(){
        TestData testData = new TestData();
        Account a = new Account(name = 'Test');
        insert a;
        Clinical_Trial_Profile__c  ctp = testData.ctp;
        Study_Site__c st= new Study_Site__c(
            Name = 'Test Site',
            Site__c = a.id,
            Clinical_Trial_Profile__c = ctp.Id,
            Principal_Investigator__c = testData.piContact.Id,
            Study_Site_Key__c = 'AEWR5436');
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
        
        Participant__c participantDel1 = new Participant__c();
        participantDel1.Email__c = 'Test01@mail.ru';
        participantDel1.First_Name__c = 'testName';
        participantDel1.Last_Name__c = 'testLastName';
        participantDel1.Phone__c = '141241';
        participantDel1.Phone_Type__c = 'Home';
        
        ParticipantInformationRemote.connectDelegateToPatient(JSON.serialize(participant),
                                                             JSON.serialize(participantDel),
                                                             st.id,
                                                             true,
                                                             JSON.serialize(participantDel1),
                                                             true);
        
    }
    
    @isTest
    static void testupdatePatientInfoAndStatusWithDelegateCC(){
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
            PE_COMMON_FIELDS.add('(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)');
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
        
        ParticipantInformationRemote.updatePatientInfoAndStatusWithDelegateCC(JSON.serialize(testData.participant),
                                                                              JSON.serialize(testData.pe),
                                                                              JSON.serialize(path),
                                                                              testData.pe.id, 
                                                                              JSON.serialize(participantDel),
                                                                              null,
                                                                              true,
                                                                              true,
                                                                              'test',
                                                                              JSON.serialize(testData.piContact));
        }
    }
    
    @isTest
    static void testcheckExisitingParticipant(){
        TestData testData = new TestData();
        ParticipantInformationRemote.checkExisitingParticipant('Firstname',
                                                               'Lastname',
                                                               'Test01@mail.ru',
                                                               testData.participant.id);
        Contact con = [SELECT Id, FirstName, LastName, Name, Email, Phone, userCommunytyType__c 
            FROM Contact WHERE Id=:testData.piDelegateContact.Id];
        ParticipantInformationRemote.checkExisitingParticipant(con.FirstName,
            con.Lastname,
            con.Email,
            testData.participant.id);
        
        ParticipantInformationRemote.checkExisitingParticipant(testData.participant.First_Name__c,
            testData.participant.Last_Name__c,
            testData.participant.Email__c,
            testData.participant.id);    
    }
    
    @isTest
    static void testgetPESHrecord(){
        TestData testData = new TestData();
        Participant_Enrollment__c pe = testData.pe;
        pe.Participant_Status__c = 'Eligibility Passed';
        update pe;
        ParticipantInformationRemote.getPESHrecord(testData.pe.id);
    }
    
    @isTest
    static void testupdateParticipantAndDelegates(){
        TestData testData = new TestData();
        integer i=integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        
        Participant__c participant = new Participant__c();
        participant.Email__c = 'testuser'+i+'@cc.vv';
        participant.First_Name__c = 'testName'+i;
        participant.Last_Name__c = 'testUser'+i;
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        insert participantDel;
        List<Participant__c> pdList = new List<Participant__c>();
        pdList.add(participantDel);
        
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = testData.participant.id,
            Contact__c = testData.piContact.id);
        insert pd;
        List<String> pList = new List<String>();
        pList.add(pd.id);
        System.runAs(testData.piUser) {
        testData.participant.Adult__c = true;
        ParticipantInformationRemote.updateParticipantAndDelegates(testData.pe.Id,
                                                                  JSON.serialize(testData.participant),
                                                                  JSON.serialize(cn),
                                                                  JSON.serialize(pdList),
                                                                  pList,
                                                                  false,
                                                                  testData.ss.id);
        /*ParticipantInformationRemote.updatePatientInfoWithDelegate(JSON.serialize(testData.participant),
                                                                  JSON.serialize(testData.pe),
                                                                  JSON.serialize(pdList),
                                                                   JSON.serialize(testData.piUser),
                                                                   JSON.serialize(cn)
                                                                  );*/
        }
    }
    
    @isTest
    static void testcheckPILevel(){
        TestData testData = new TestData();
        System.runAs(testData.piUser) {
            ParticipantInformationRemote.checkPILevelI(testData.ss.Id);
        }
    }

    @isTest
    static void testupdatePatientInfoWithDelegate() {
        TestData testData = new TestData();
        Participant__c part = [SELECT
                Id,
                Name,
                Adult__c,
                First_Name__c,
                Last_Name__c,
                Email__c,
                Status__c,
                Balance__c,
                Contact__c,
                Mailing_Country_Code__c,
                Mailing_Country__c,
                Contact__r.AccountId
            FROM Participant__c
            WHERE Last_Name__c = 'ParticipantTD'
        ];
        Participant__c part1 = [
            SELECT Id, Adult__c, Emancipation_in_progress__c
            FROM Participant__c
            WHERE Id = :testData.pe.Participant__c
        ];
        Participant_Enrollment__c peDetails = [
            SELECT
                Id,
                Name,
                External_Key__c,
                Participant_Contact__c,
                Participant_Status__c,
                Participant_Contact__r.Visit_Results_OptIn__c,
                Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_occurred_date__c,
                Initial_visit_scheduled_time__c,
                Initial_visit_occurred_flag__c,
                Initial_visit_scheduled_flag__c,
                Screening_ID__c,
                Participant__c,
                Medical_Record_Review_Completed_Date__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Principal_Investigator__r.Name,
                Study_Site__r.Principal_Investigator__r.Title,
                Participant__r.Mailing_Country_Code__c,
                Participant__r.Mailing_Country__c,
                Participant__r.Adult__c,
                Participant__r.Emancipation_in_progress__c
            FROM Participant_Enrollment__c
            WHERE Participant__c = :part1.Id
        ];
        part.Adult__c = true;
        byPassTriggersMethod();
        update part;
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        Test.startTest();
        try {
            ParticipantInformationRemote.updatePatientInfoWithDelegate(JSON.serialize(part),
                                                                    JSON.serialize(peDetails),
                                                                    JSON.serialize(participantDel),
                                                                    JSON.serialize(testData.piUser),
                                                                    JSON.serialize(testData.piContact));
        } catch(Exception ex){}
        ParticipantInformationRemote.getUser(testData.piUser.ContactId);
        ParticipantInformationRemote.checkDelegateAge(JSON.serialize(part),JSON.serialize(participantDel));
        ParticipantInformationRemote.checkNeedsGuardian(JSON.serialize(part));
        Test.stopTest();
    }

    @isTest
    static void testUpdatePatientStatusHelper() {
        TestData testData = new TestData();
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';

        Test.startTest();
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add('(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)');
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');  
            //byPassTriggersMethod();
            
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
            
            ParticipantInformationRemote.updatePatientStatusHelper(JSON.serialize(testData.pe),
                JSON.serialize(path),
                true,
                false,
                PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
                false
            );
            ParticipantInformationRemote.updatePatientInfoAndStatusWithDelegate(
                JSON.serialize(testData.participant),
                JSON.serialize(testData.pe),
                JSON.serialize(path),
                testData.pe.Id,
                JSON.serialize(participantDel),
                JSON.serialize(testData.piUser),
                false,
                false,
                PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
                JSON.serialize(testData.piContact)
            );
            try{
                ParticipantInformationRemote.updatePatientInfoAndStatusWithDelegate(
                    JSON.serialize('test'),
                    JSON.serialize(testData.pe),
                    JSON.serialize(path),
                    testData.pe.Id,
                    JSON.serialize(participantDel),
                    JSON.serialize(testData.piUser),
                    false,
                    false,
                    PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
                    JSON.serialize(testData.piContact)
                );

            }catch(Exception ex){}
        }
        Test.stopTest();
    }

    @isTest
    static void testPrepareParticipantWorkflowHelper() {
        TestData testData = new TestData();
        testData.createPatientDelegate();
        List<Contact> delegate = [Select Id FROM Contact WHERE Email='jsmith@somemail.com'];
        List<String> statusList = new List<String>{
            'Recieved',
            'Pre-review Passes',
            'Contact Attempted',
            'Successfully Contacted'
        };
        Set<Id> piContactIds = new Set<Id>{testData.piContact.Id};
        Test.startTest();
        System.runAs(testData.piUser) {
            ParticipantWorkflowService.prepareParticipantWorkflowHelper(
                (String)testData.pe.Id,
                'PI',
                null
            );

            ParticipantWorkflowService.filterStatusesForCTPSettings(
                statusList,
                testData.ctp);

            ParticipantWorkflowService.getPIContactSalutationAndNames(piContactIds);
            ParticipantWorkflowService.getPIContactNames(piContactIds);
            ParticipantWorkflowService.getContactFullNamesFromParticipants(piContactIds);
            ParticipantWorkflowService.getPIContactNameDetails(piContactIds);
           /* ParticipantWorkflowService.populateSObjectFromPicklistField(
                SObject obj,
                String objectNameAlias,
                ParticipantWorkflowFieldWrapper field,
                Participant_Workflow_Form_Field__mdt fieldSetting
            );*/
        }
        Test.stopTest();
    }

    @isTest
    static void testParticipantWorkflow() {
        TestData testData = new TestData();
        Participant_Enrollment__c pe = [
            SELECT
                Id,
                Name,
                External_Key__c,
                Participant_Contact__c,
                Participant_Status__c,
                Participant_Contact__r.Visit_Results_OptIn__c,
                Clinical_Trial_Profile__r.Shareback_Availability_Timing__c,
                Initial_visit_scheduled_date__c,
                Initial_visit_occurred_date__c,
                Initial_visit_scheduled_time__c,
                Initial_visit_occurred_flag__c,
                Initial_visit_scheduled_flag__c,
                Screening_ID__c,
                Participant__c,
                Medical_Record_Review_Completed_Date__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Principal_Investigator__r.Name,
                Study_Site__r.Principal_Investigator__r.Title,
                Participant__r.Mailing_Country_Code__c,
                Participant__r.Mailing_Country__c
            FROM Participant_Enrollment__c
            WHERE Id = :testData.pe.Id
        ];

        Time myTime = Time.newInstance(1, 2, 3, 0);
        pe.Initial_visit_scheduled_date__c = System.today();
        pe.Initial_visit_scheduled_time__c = myTime;

        byPassTriggersMethod();
        update pe;
        Participant_Enrollment_Status_History__c pehistory1 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
            Additional_Notes__c = 'Test Notes testing testclass code on this date by  #### test user',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user',
            Backward_Bulk_Update__c = true
        );
        insert pehistory1;
        Participant_Enrollment_Status_History__c pehistory2 = new Participant_Enrollment_Status_History__c(
            Date__c = Datetime.now(),
            Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,
            Additional_Notes__c = 'Test Notes testing testclass code on this date by test user',
            ParticipantEnrollment__c = testData.pe.Id,
            Non_Enrollment_Reason__c= 'PI Decision',
            Notes__c='Test Notes testing testclass code on this date by test user',
            Backward_Bulk_Update__c = true
        );
        insert pehistory2;

        Test.startTest();
        System.runAs(testData.piUser) {
            ParticipantWorkflowService.prepareParticipantWorkflowHelper(
                (String)pe.Id,
                'PI',
                null
            );
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add('(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)');
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__r.Response_Status_Code__c');  
            Participant_Enrollment__c peRec = ParticipantEnrollmentService.getParticipantEnrollment(
                pe.Id,
                CommunityService.USER_MODE_PI,
                null,
                PE_COMMON_FIELDS
            );
            ParticipantWorkflowService.ParticipantWorkflowWrapper path = ParticipantWorkflowService.prepareParticipantWorkflow(
                testData.ctp,
                peRec
            );
        }
        Test.stopTest();
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
    }
    
}