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
        List<Participant_Enrollment_Status_History__c> lstPESH  = new List<Participant_Enrollment_Status_History__c> ();
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        pesh.Date__c = Datetime.now();
        pesh.Status__c = 'Eligibility Passed'; 
        pesh.ParticipantEnrollment__c =  testData.pe.Id;
        lstPESH.add(pesh);
        Participant_Enrollment_Status_History__c pesh2 = new Participant_Enrollment_Status_History__c();
        pesh2.Date__c = Datetime.now();
        pesh2.Status__c = 'Participant No Show'; 
        pesh2.ParticipantEnrollment__c =  testData.pe.Id;
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
    public static void testPeshRecordforSuccesfulyengaed(){
        TestData testData = new TestData();
        List<Participant_Enrollment_Status_History__c> lstPESH  = new List<Participant_Enrollment_Status_History__c> ();
        Participant_Enrollment_Status_History__c pesh = new Participant_Enrollment_Status_History__c();
        pesh.Date__c = Datetime.now();
        pesh.Status__c = 'Successfully re-engaged'; 
        pesh.ParticipantEnrollment__c =  testData.pe.Id;
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
             Test.startTest();
        byPassTriggersMethod();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test011@mail.ru';
        participant.First_Name__c = 'testName1';
        participant.Last_Name__c = 'testLastName1';
        participant.Middle_Name__c = 'ftfusy';
        participant.Nickname__c = 'ghjfgiy';
        participant.Suffix__c = 'Mr';
        participant.Birth_Day__c = '12';
        participant.Birth_Month__c = '12';
        participant.Birth_Year__c = '1995';
        participant.Age__c = 21;
        participant.Adult__c = true;
        participant.Mailing_Country_Code__c = 'US';
        participant.Mailing_State_Code__c = 'NC';
        participant.Mailing_Zip_Postal_Code__c = '5875';
        participant.Phone__c = '64747689';
        participant.Gender__c = 'Female';
        participant.Phone_Type__c = 'Home';
        participant.ZIP_Code__c = '6566';
        participant.Preferred_Language__c = 'en_US';
        
        participant.Date_of_Birth__c = '2000-04-18';
        insert participant;
        byPassTriggersMethod();
   
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
            Contact objCon = new Contact();
        objCon.Participant_Phone_Opt_In_Permit_Phone__c = true;
        objCon.Participant_Opt_In_Status_Emails__c = true; 
        objCon.Participant_Opt_In_Status_SMS__c = true;
        
        Participant__c participant = new Participant__c();
        participant.Email__c = 'Test01@mail.ru';
        participant.First_Name__c = 'testName';
        participant.Last_Name__c = 'testLastName';
        participant.Suffix__c = 'S';
         participant.Contact__c = objCon.id;
        participant.Middle_Name__c = 'Mr';
        insert participant;
        

        Participant__c participantDel1 = new Participant__c();
        participantDel1.Email__c = 'Test0198@mail.ru';
        participantDel1.First_Name__c = 'testName1';
        participantDel1.Last_Name__c = 'testLastName1';
     //   participantDel1.Phone__c = '14124189';
        participantDel1.Phone_Type__c = 'Mobile';
        participantDel1.Birth_Year__c = '1990';
        
        
                    Study_Site__c ss = [SELECT Id,Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,Suppress_Participant_Emails__c,Study_Site_Type__c,Principal_Investigator__c FROM Study_Site__c
                               LIMIT 1];
        
              Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Study_Site__c = ss.Id,
                Patient_ID__c = '12345678',
                Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
                Participant__c = participant.Id
            );
        
          Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = objCon.Id,
                Contact__r = objCon,
                Participant__c = participantDel1.Id,
                Participant__r = participant
            );
          ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                     pe.id,
                    'del@email.delemail',
                    'firstName',
                    'lastName',
                    participantDel1.id
                );
 
        Test.startTest();
        System.runAs(testData.piUser){
            try {
           
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel1),
                     JSON.serialize(ddInfo), 
                    participant.Id,
                    JSON.serialize(participant),
                    true,
                    null,
                    JSON.serialize(objCon),
                    true,
                    false,
                    pe.id
                );
                ParticipantInformationRemote.getDelegates(String.valueOf(participant.Id));
            }catch(exception e) {system.debug('teste');}}
        Test.stopTest();
    }
        @IsTest
    static void testCreateParticipantDelegate2() {
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
           
        Contact objCon = new Contact();
        objCon.Participant_Phone_Opt_In_Permit_Phone__c = true;
        objCon.Participant_Opt_In_Status_Emails__c = true; 
        objCon.Participant_Opt_In_Status_SMS__c = true;
        
        Participant__c participant = new Participant__c();
        participant.Email__c = 'del@email.delemail';
        participant.First_Name__c = 'firstName';
        participant.Last_Name__c = 'lastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        participant.Contact__c = objCon.id;
        insert participant;
        
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
       // participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        
  
                    Study_Site__c ss = [SELECT Id,Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,Suppress_Participant_Emails__c,Study_Site_Type__c,Principal_Investigator__c FROM Study_Site__c
                               LIMIT 1];
        
              Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Study_Site__c = ss.Id,
                Patient_ID__c = '12345678',
                Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
                Participant__c = participant.Id
            );
          Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = objCon.Id,
                Contact__r = objCon,
                Participant__c = participant.Id,
                Participant__r = participant
            );
          ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                     pe.id,
                    'del@email.delemail',
                    'firstName',
                    'lastName',
                    participant.id
                );
 
        Test.startTest();
        System.runAs(testData.piUser){
            try {
                AddPatientByPIRemote.createParticipantDelegate(
                    null,
                    null,
                    participant.Id,
                    JSON.serialize(participant),
                    true,
                    null,
                    JSON.serialize(objCon),
                    true,
                    false,
                    pe.id
                );  
              
                ParticipantInformationRemote.getDelegates(String.valueOf(participant.Id));
            }catch(exception e) {system.debug('teste');}}
        Test.stopTest();
    } 
        @IsTest
    static void testCreateParticipantDelegate3() {
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
           
        Contact objCon = new Contact();
        objCon.Participant_Phone_Opt_In_Permit_Phone__c = true;
        objCon.Participant_Opt_In_Status_Emails__c = true; 
        objCon.Participant_Opt_In_Status_SMS__c = true;
        
        Participant__c participant = new Participant__c();
        participant.Email__c = '';
        participant.First_Name__c = 'firstName';
        participant.Last_Name__c = 'lastName';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        participant.Contact__c = objCon.id;
       insert participant;
        
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
       // participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        
  
                    Study_Site__c ss = [SELECT Id,Clinical_Trial_Profile__r.Suppress_Participant_Emails__c,Suppress_Participant_Emails__c,Study_Site_Type__c,Principal_Investigator__c FROM Study_Site__c
                               LIMIT 1];
        
              Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Study_Site__c = ss.Id,
                Patient_ID__c = '12345678',
                Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
                Participant__c = participant.Id
            );
          Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = objCon.Id,
                Contact__r = objCon,
                Participant__c = participantDel.Id,
                Participant__r = participant
            );
          ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                     pe.id,
                    'del@email.delemail',
                    'firstName',
                    'lastName',
                    participant.id
                );
 
        Test.startTest();
        System.runAs(testData.piUser){
            try {
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel),
                    JSON.serialize(ddInfo),
                    participant.id,
                    JSON.serialize(participant),
                    true,
                    null,
                    JSON.serialize(objCon),
                    true,
                    false,
                    pe.id
                );  
              
                ParticipantInformationRemote.getDelegates(String.valueOf(participant.Id));
            }catch(exception e) {system.debug('teste');}}
        Test.stopTest();
    }
   /*    @IsTest
    static void testCreateParticipantDelegate2() {
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
        
                    Account a = new Account(name = 'Test');
            insert a;
            integer i=integer.valueOf(Math.random());
            Contact cn = New Contact();
            cn.LastName = 'testUser'+i;
            cn.FirstName = 'testName'+i;
            cn.Phone_Type__c = 'Home';
            cn.email = 'testuser'+i+'@cc.vv';
          //  cn.MailingPostalCode = '3733';
            cn.Birthdate = system.today();
            cn.AccountId = a.Id;
            
            insert cn; 
            
            Study_Site__c ss = [SELECT Id,Principal_Investigator__c FROM Study_Site__c
                               LIMIT 1];
            String userLanguage = 'ru';
            String birthdayToReceiveAlert = String.valueOf(Datetime.now().addDays(7).addYears(-18))
                .substring(0, 10);
            Participant__c participant = new Participant__c(
                First_Name__c = 'NewP',
                Last_Name__c = 'NewP',
                Phone__c = '11213232',
                Email__c = 'NewP@email.com',
                Mailing_Country_Code__c = 'US',
                Mailing_State_Code__c = 'NY',
               // Contact__c = cn.Id,
                Date_of_Birth__c = birthdayToReceiveAlert,
                ZIP_Code__c = '15646',
                Day_of_Birth__c = date.today().addyears(-18),
                Birth_Year__c = '2001',
                Adult__c = true
            );
          //  insert participant;
            
            Participant__c participantDel = new Participant__c();
            participantDel.Email__c = 'Test01@mail.ru';
            participantDel.First_Name__c = 'testNamqwee';
            participantDel.Last_Name__c = 'testNamcwe';
            participantDel.Phone__c = '1122';
            //participantDel.Email__c = 'NefdwfwP@email.com';
            participantDel.Date_of_Birth__c = birthdayToReceiveAlert; 
            participantDel.ZIP_Code__c = '1566';
            participantDel.Day_of_Birth__c = date.today().addyears(-20);
            participantDel.Birth_Year__c = '2001';
            participantDel.Adult__c = true;
            insert participantDel;
            
            Participant_Enrollment__c pe = new Participant_Enrollment__c(
                Study_Site__c = ss.Id,
                Patient_ID__c = '12345678',
                Participant_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
                Participant__c = participant.Id
            );
            
            Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
                Contact__c = cn.Id,
                Contact__r = cn,
                Participant__c = participantDel.Id,
                Participant__r = participant
            );
            //  insert patientDelegate;
            
            ReferHealthcareProviderRemote.HealthcareProvider ddInfo = ReferHealthcareProviderRemote.checkDuplicate(
                    pe.Id,
                    'del@email.delemail',
                    'firstName',
                    'lastName',
                    null
                );
 
        Test.startTest();
        System.runAs(testData.piUser){
            try {
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participant),
                 JSON.serialize(ddInfo),
                    participant.Id,
                    JSON.serialize(participantDel),
                    false,
                    null,
                    JSON.serialize(Cn),
                    true
                );  
             
            
            }catch(exception e) {system.debug('teste');}}
        Test.stopTest();
    } */
    
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
                null,false,false
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
            path.steps[path.currentStepInd].notes = 'note';
            ParticipantInformationRemote.updatePatientStatusCC(
                JSON.serialize(path),
                testData.pe.Id,
                false,
                true,
                null,false,false
            );
            ParticipantInformationRemote.updatePatientStatus(
                JSON.serialize(path),
                testData.pe.Id,
                false,
                true,
                null,false,false
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
            path.steps[path.currentStepInd].notes = 'note';
            
            ParticipantInformationRemote.updatePatientStatusHelper(JSON.serialize(testData.pe),JSON.serialize(path),false,true,null,false,false);
            path.steps[path.currentStepInd + 1].state = 'neutral';
            path.steps[path.currentStepInd + 1].title = 'Inital Visit';
            // ParticipantInformationRemote.updateNotes(path, testData.pe, null, false);
            //  ParticipantInformationRemote.updateWithDividerWithNotes(path, testData.pe, null);
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
        
    }
    
    @isTest
    static void testgetMedicalHistory(){
        TestData testData = new TestData();
        ParticipantInformationRemote.getMedicalHistory(testData.pe.Id);
        
    }
      @isTest
    static void testdisconnectDelegateToPatient(){
     Test.startTest();
           Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
           // AccountId = participant.Contact__r.AccountId,
           // Current_Participant_Enrollment__c = pe.Id,
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = p.Id,
            Participant__r = p
        );
        insert patientDelegate;
        ParticipantInformationRemote.disconnectDelegateToPatient(patientDelegate.Id);
          Test.stopTest();
            
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
        insert participantDel;
        
 
           integer i=integer.valueOf(Math.random());
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            Phone_Type__c = 'Home',
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        
        insert cn; 
        
        Participant__c participantDel1 = new Participant__c();
        participantDel1.Email__c = 'Test01@mail.ru';
        participantDel1.First_Name__c = 'testName';
        participantDel1.Last_Name__c = 'testLastName';
      //  participantDel1.Phone__c = '141241';
      //  participantDel1.Phone_Type__c = 'Home';
        participantDel1.Contact__c = cn.Id;
        participantDel1.Birth_Year__c = '1990';
        insert participantDel1;
        
       Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = participant.id,
            Status__c = 'Active',
            Contact__c = cn.id);
        insert pd; 

         ReferHealthcareProviderRemote.HealthcareProvider ddi = new  ReferHealthcareProviderRemote.HealthcareProvider();
        ddi.firstName = participantDel1.First_Name__c;
        ddi.contactId = participantDel1.Contact__c;
        ddi.lastName = participantDel1.Last_Name__c;
        ddi.email = participantDel1.Email__c;
        ddi.participantId = participantDel1.Id;
        
         ReferHealthcareProviderRemote.HealthcareProvider ddi2 = new  ReferHealthcareProviderRemote.HealthcareProvider();
        ddi2.firstName = participantDel1.First_Name__c;
        ddi2.contactId = participantDel1.Contact__c;
        ddi2.lastName = participantDel1.Last_Name__c;
        ddi2.email = participantDel1.Email__c;
        
        ParticipantInformationRemote.connectDelegateToPatient(JSON.serialize(participant),
                                                              JSON.serialize(participantDel),
                                                              st.id,
                                                              false,
                                                              JSON.serialize(participantDel1),
                                                              false
                                                              );
        
        ParticipantInformationRemote.connectDelegateToPatient(JSON.serialize(participant),
                                                              JSON.serialize(participantDel1),
                                                              st.id,
                                                              true,
                                                              JSON.serialize(ddi),
                                                              true
                                                              );
        
                ParticipantInformationRemote.connectDelegateToPatient(JSON.serialize(participant),
                                                              JSON.serialize(participantDel1),
                                                              st.id,
                                                              true,
                                                              JSON.serialize(ddi2),
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
            ParticipantInformationRemote.checkNeedsGuardian(JSON.serialize(testData.participant)); 
            ParticipantInformationRemote.checkDelegateAge(JSON.serialize(testData.participant),JSON.serialize(participantDel)); 
            ParticipantInformationRemote.updatePatientStatusCCHelper(JSON.serialize(testData.pe),
                                                                     JSON.serialize(path),true,true,PEStatusState.PE_STATUS_CONTACT_ATTEMPTED,false);  
            ParticipantInformationRemote.getUser(testData.piContact.Id);              
            
      
        }
    } 
    
    @isTest
    static void testcheckExisitingParticipant(){
        TestData testData = new TestData();
        test.starttest();
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = New Contact(
            LastName = 'LastnameCheck',
            FirstName = 'FirstnameCheck',
            Phone_Type__c = 'Home',
            email = 'Test01@mail.ru',
            Phone = '9876543211',
            AccountId = a.id);
        
        insert cn;
        
        ParticipantInformationRemote.checkExisitingParticipant('FirstnameCheck',
                                                               'LastnameCheck',
                                                               'Test01@mail.ru',
                                                               testData.participant.id);
        test.stoptest();
    }
    
    @isTest
    static void testcheckExisitingParticipant1(){
        TestData testData = new TestData();
        test.starttest();
        Participant__c participant = new Participant__c();
        participant.Email__c = 'testuserCheck@gmail.comm';
        participant.First_Name__c = 'testNamecheck';
        participant.Last_Name__c = 'testUserNamecheck';
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        
        insert participant;
        ParticipantInformationRemote.checkExisitingParticipant('testNamecheck',
                                                               'testUserNamecheck',
                                                               'testuserCheck@gmail.comm',
                                                               testData.participant.id);
        test.stoptest();
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
        byPassTriggersMethod();
        test.startTest();
        integer i=integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            Phone_Type__c = 'Home',
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        
        insert cn;
        
        Participant__c participant = new Participant__c();
        participant.Email__c = 'testuser'+i+'@cc.vv';
        participant.First_Name__c = 'testName'+i;
        participant.Last_Name__c = 'testUser'+i;
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        participant.Phone_Type__c = 'Mobile';
        insert participant;
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        participantDel.Contact__c = cn.Id;
        participantDel.Mailing_Country_Code__c = 'US';
        participantDel.Delegate_Consent_SMS__c = true; 
        insert participantDel;
        List<Participant__c> pdList = new List<Participant__c>();
        pdList.add(participantDel);
        
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = participant.id,
            Status__c = 'Active',
            Contact__c = testData.piContact.id);
        insert pd;
        List<String> pList = new List<String>();
        pList.add(pd.id);
        System.runAs(testData.piUser) {
           
            ParticipantInformationRemote.updateParticipantAndDelegates(testData.pe.Id,
                                                                       JSON.serialize(participantDel),
                                                                       JSON.serialize(cn),
                                                                       JSON.serialize(pdList),
                                                                       pList,
                                                                       true,
                                                                       testData.ss.id);
            ParticipantInformationRemote.updateParticipantAndDelegates(testData.pe.Id,
                                                                       JSON.serialize(participant),
                                                                       JSON.serialize(cn),
                                                                       JSON.serialize(pdList),
                                                                       pList,
                                                                       false,
                                                                       testData.ss.id);
                        ParticipantInformationRemote.updateParticipantAndDelegates(testData.pe.Id,
                                                                       JSON.serialize(participantDel),
                                                                       JSON.serialize(cn),
                                                                       JSON.serialize(pdList),
                                                                       pList,
                                                                       false,
                                                                       testData.ss.id);
            test.stopTest();
         }
    }
   
    @isTest
    static void testupdateParticipantAndDelegates1(){
        TestData testData = new TestData();
        integer i=integer.valueOf(Math.random());
        Account a = new Account(name = 'Test');
        insert a;
        Contact cn = New Contact(
            LastName = 'testUser'+i,
            FirstName = 'testName'+i,
            Phone_Type__c = 'Home',
            email = 'testuser'+i+'@cc.vv',
            AccountId = a.id);
        
        insert cn;
        
        Participant__c participant = new Participant__c();
        participant.Email__c = 'testuser'+i+'@cc.vv';
        participant.First_Name__c = 'testName'+i;
        participant.Last_Name__c = 'testUser'+i;
        participant.Suffix__c = 'S';
        participant.Middle_Name__c = 'Mr';
        participant.Mailing_Country_Code__c = 'GB';
        insert participant;
        Participant__c participantDel = new Participant__c();
        participantDel.Email__c = 'Test01@mail.ru';
        participantDel.First_Name__c = 'testName';
        participantDel.Last_Name__c = 'testLastName';
        participantDel.Phone__c = '141241';
        participantDel.Phone_Type__c = 'Home';
        participantDel.Contact__c = cn.Id;
        participantDel.Delegate_Consent_SMS__c = false; 
        insert participantDel;
        List<Participant__c> pdList = new List<Participant__c>();
        pdList.add(participantDel);
        
        Patient_Delegate__c pd = new Patient_Delegate__c(
            Participant__c = testData.participant.id,
            Status__c = 'Active',
            Contact__c = testData.piContact.id);
        insert pd;
        List<String> pList = new List<String>();
        pList.add(pd.id);
        System.runAs(testData.piUser) {
            
            ParticipantInformationRemote.updateParticipantAndDelegates(testData.pe.Id,
                                                                       JSON.serialize(participant),
                                                                       JSON.serialize(cn),
                                                                       JSON.serialize(pdList),
                                                                       pList,
                                                                       false,
                                                                       testData.ss.id);
                }
    }
    @isTest
    static void testUpdatePatientInfoWithDelegate(){
        TestData testData = new TestData();
        Account a = new Account(name = 'Test');
        insert a;
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
            Participant__c participantDel = new Participant__c();
            participantDel.Email__c = 'Test011@mail.ru';
            participantDel.First_Name__c = 'testName1';
            participantDel.Last_Name__c = 'testLastName1';
            participantDel.Date_of_Birth__c = '2000-04-18';
            Contact cn = New Contact(
                LastName = 'testUser'+'1',
                FirstName = 'testName'+'1',
                email = 'testuser'+'1'+'@cc.vv',
                AccountId = a.id);
            ParticipantInformationRemote.updatePatientInfoWithDelegate(
                JSON.serialize(testData.participant),
                JSON.serialize(testData.pe),
                JSON.serialize(participantDel),
                '',
                JSON.serialize(cn)
                
            );
            try{
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
            }
            catch(exception ex){
                system.debug('>>>excc>>'+ex.getMessage());
            }
        }
        Test.stopTest();
        
    } 
    
    @isTest
    static void testUpdatePatientInfoWithDelegate_Existing(){
        TestData testData = new TestData();
        Account a = new Account(name = 'Test');
        insert a;
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
            Participant__c participantDel = new Participant__c();
            participantDel.Email__c = 'Test011@mail.ru';
            participantDel.First_Name__c = 'testName1';
            participantDel.Last_Name__c = 'testLastName1';
            participantDel.Date_of_Birth__c = '2000-04-18';
            participantDel.Birth_Year__c = '2000';
            Contact cn = New Contact(
                LastName = 'testLastName1',
                FirstName = 'testName1',
                email = 'Test011@mail.ru',
                AccountId = a.id);
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
            
        }
        Test.stopTest();
        
    } 
    
    @isTest
    static void testGetMasked(){
        
        TestData testData = new TestData();
        
        Test.startTest();
        System.runAs(testData.piUser) {
            
            ParticipantInformationRemote.getMasked(
                true,
                'CC',
                'Test Name'
            );
            
            ParticipantInformationRemote.getMasked(
                true,
                'PI',
                'Test Name'
            );
        }
        Test.stopTest();
    } 
    
     static void byPassTriggersMethod() {
                TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
        );
         TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.contextExecuteHandler.class
        );
       
          TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.CreateContactsForParticipantsHandler.class
        );
          TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.createContactsForParticipants.class
        );
           TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.changeUserEmailOnParticipantEmailChange.class
        );
          TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.ChangeUserEmailOnParticipantEmailChangeHandler.class
        );
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
            ContactTriggerHandler.CreateUserForDelegateContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.CreateUserForCCContactHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantAndUserEmailsOnEmailChangeHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContactTriggerHandler.UpdateParticipantDetailsHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdatePEAndContactLastNameHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreatePrimaryDelegateForMinor.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class
        );
        TriggerHandlerExecutor.bypassHandler(
            PatientDelegateTriggerHandler.CreateNewAssignmentNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantTriggerHandler.UpdateContactDetailsFromParticipant.class
        );
    }
    
}