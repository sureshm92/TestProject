/**
 * Created by Leonid Bartenev
 */

@IsTest
private without sharing class Test_AddPatientByPIRemote {
    //deprecated
     @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
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
            //PE_COMMON_FIELDS.add('Date_of_Birth__c');
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
            
            AddPatientByPIRemote.updateParticipant(JSON.serialize(testData.participant));
            AddPatientByPIRemote.updatePatientInfo(JSON.serialize(testData.participant), JSON.serialize(testData.pe));
            AddPatientByPIRemote.getUserLanguage();
            //AddPatientByPIRemote.trimParticipantFields(testData.participant);
            AddPatientByPIRemote.checkNeedsGuardian(JSON.serialize(testData.participant));
            AddPatientByPIRemote.checkDuplicateDelegate('del@del.com','del','del');
            AddPatientByPIRemote.checkDelegateAge(JSON.serialize(testData.participant),JSON.serialize(participantDel));
            AddPatientByPIRemote.assignParticipantPermissions(testData.ss.Id,testData.piContact.Id);
            AddPatientByPIRemote.savePER(null,
            JSON.serialize(testData.pe),
            testData.ss.Id,
            JSON.serialize(participantDel),
            JSON.serialize(testData.participant),
            null,
            JSON.serialize(objCon),
            true,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            null);
            
            AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel),
                    null,
                    testData.participant.Id,
                    JSON.serialize(testData.participant),
                    false,
                    null,
                    JSON.serialize(objCon),
                    true,
                    false,
                    null
                );
                AddPatientByPIRemote.createParticipantDelegate(
                    JSON.serialize(participantDel1),
                    null,
                    testData.participant.Id,
                    JSON.serialize(testData.participant),
                    false,
                    null,
                    JSON.serialize(objCon),
                    true,
                    false,
                    null
                );
                
        }
        Test.stopTest();
    }
    
    @IsTest
    static void updateState1() {
        TestData testData = new TestData();
        
        System.runAs(testData.piUser) {
            List<String> PE_COMMON_FIELDS = new List<String>();
            PE_COMMON_FIELDS.addAll(ParticipantEnrollmentService.PE_COMMON_FIELDS);
            PE_COMMON_FIELDS.add(
                '(SELECT Id,Date__c,Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__r WHERE Status__c =\'Eligibility Passed\' ORDER BY CreatedDate DESC LIMIT 1)'
            );
            PE_COMMON_FIELDS.add('Clinical_Trial_Profile__r.Initial_Visit_Required__c');
            PE_COMMON_FIELDS.add('Study_Hub_Log__c');
            //PE_COMMON_FIELDS.add('Date_of_Birth__c');
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
                
                 Account studySiteAccount = new Account(
                Name = 'Study Site Account',
                BillingLatitude = 41.766594,
                BillingLongitude = -74.991509,
                BillingCountry = 'United States'
            );
            insert studySiteAccount;
                
                Participant__c participant4 = new Participant__c(
                    First_Name__c = 'PI',
                    Last_Name__c = 'PI',
                    Phone__c = '8343212',
                    Email__c = '04ipremail@gmtesstail.com',
                    Mailing_Country_Code__c = 'US',
                    Mailing_State_Code__c = 'AL',
                    Adult__c = true,
                    Site__c = studySiteAccount.Id,
                    Date_of_Birth__c = '1987-03-01',
                    Contact__c = testdata.piContact.Id,
                    Mailing_Zip_Postal_Code__c = '12345'
                );
                insert participant4;
                
                
                AddPatientByPIRemote.saveParticipants(
                JSON.serialize(participant4),
                JSON.serialize(testData.pe),
                null,
                testData.ss.Id,
                false,
                JSON.serialize(participantDel1),
                null,
                false,
                false,
                false,
                false,
                false,
                JSON.serialize(objCon),
                true);
                
                
                AddPatientByPIRemote.saveParticipant(
                JSON.serialize(participant4),
                JSON.serialize(testData.pe),
                null,
                testData.ss.Id,
                false,
                JSON.serialize(participantDel1),
                null,
                false,
                false,
                false,
                false,
                false,
                JSON.serialize(objCon),
                true
                );
                
                AddPatientByPIRemote.getInitData(testData.ss.Id);
                
                Test.stopTest();
        }
        
    }
}