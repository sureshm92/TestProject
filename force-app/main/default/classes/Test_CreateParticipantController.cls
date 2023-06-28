@isTest
public class Test_CreateParticipantController {
    public static Participant_Enrollment__c peList;
    @TestSetup
    static void init(){
        TestData.loadTestData();
        TestData td = new TestData();
        MulesoftToken__c setting = new MulesoftToken__c();
        setting.Name = 'Test';
        setting.Named_Credentials_Name__c = 'Test_Named_Credential';
        setting.Token__c = 'test_token';
        setting.Expiration_Date__c = DateTime.now().addHours(1);
        insert setting;
        
        List<Clinical_Trial_Profile__c> ctpList = [Select id,E_Consent_Configuration__c,StudyGUID__c from Clinical_Trial_Profile__c where id=:td.ctp.id];
        for(Clinical_Trial_Profile__c ctps : ctpList){
            ctps.id = td.ctp.id;
            ctps.E_Consent_Configuration__c = true;
            ctps.StudyGUID__c = 'testids';
        }
        update ctpList;
        
        E_Consent_Vendor__c completeConsent = new E_Consent_Vendor__c(Name = 'Complete Consent');
        insert completeConsent;
        
        List<Study_Site__c> ssList = [Select id,SiteGuid__c,E_Consent_Vendor__c from Study_Site__c where id=:td.ss.id];
        for(Study_Site__c studies: ssList){
            studies.id = td.ss.id;
            studies.SiteGuid__c = 'test';
            studies.E_Consent_Vendor__c=completeConsent.id;
        }
        update ssList;
        
        List<Participant_Enrollment__c> peList = [Select Id,ParticipantGUID__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                                  Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                                                  Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id];
        
        for (Participant_Enrollment__c peobj : peList) {
            peobj.Participant__c = td.participant.id;
            peobj.Id = td.pe.Id;
            peobj.Study_Site__c = ssList[0].Id;  
            peobj.Clinical_Trial_Profile__c = ctpList[0].id;
        }
        update peList;
    }
    
    @isTest
    static void testgetAccessToken() {
        MulesoftToken__c setting = new MulesoftToken__c();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock_MulesoftIntegrationApi());
        String accessToken = MulesoftIntegrationApi.getAccessToken('Test');
        CreateParticipantController.getAccessToken();
        Test.stopTest();
        
        // Assertions
        System.assertNotEquals(null, accessToken);
    }
    
    @isTest
    static void testGetDocumentCollections() {
        TestData td = new TestData();
        MulesoftToken__c setting = new MulesoftToken__c();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        List<Clinical_Trial_Profile__c> ctpList=[Select id,E_Consent_Configuration__c,StudyGUID__c from Clinical_Trial_Profile__c where id=:td.ctp.id];
        
        List<Study_Site__c> ssList = [Select id,SiteGuid__c,E_Consent_Vendor__c from Study_Site__c where id=:td.ss.id];
        
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe :[Select Id,ParticipantGUID__c,Re_consent__c,Informed_Consent__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                           Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                                           Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id]){
                                               pe.ParticipantGUID__c='test';
                                               peList.add(pe);
                                           }
        update peList;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock_MulesoftIntegrationApi());
        String accessToken = MulesoftIntegrationApi.getAccessToken('Test');
        CreateConsentIntegration.documentCollectionResponse(ctpList[0].StudyGUID__c,ssList[0].SiteGuid__c,accessToken);
        CreateParticipantController.getDocumentCollections(peList[0].Id, accessToken);
        Test.stopTest();
        //System.assertEquals(mockDocumentCollections.size(), result.size(), 'The size of the returned list should match the mock document collections');
    }
    
    @isTest
    static void testParticipantCreationOnEconsent() {
        TestData td = new TestData();
        MulesoftToken__c setting = new MulesoftToken__c();
        List<Participant_Enrollment__c> peList = [Select Id,ParticipantGUID__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                                  Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id];
        
        try {
            Test.startTest();
            Map<Id, LabelValueItem> documentCollection = new Map<Id, LabelValueItem>();
            LabelValueItem documentCollection1 = new LabelValueItem('Test Document Collection (test)', 'test document collection id');
            documentCollection.put(peList[0].Id, documentCollection1);
            
            String documentCollectionJson = JSON.serialize(documentCollection);
            Test.setMock(HttpCalloutMock.class, new Mock_MulesoftIntegrationApi());
            String accessToken = MulesoftIntegrationApi.getAccessToken('Test');
            CreateParticipantController.participantCreationOnEconsent(peList[0].Id, accessToken, documentCollectionJson);
            Test.stopTest();
            
        } catch (AuraHandledException ex) {
            
        }
    }
    
    @isTest
    static void testIsCreateConsentEnabled() {
        TestData td = new TestData();
        Test.startTest();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        List<Participant_Enrollment__c> peList = [Select Id,Clinical_Trial_Profile__r.StudyGUID__c,Study_Site__c,Study_Site__r.SiteGuid__c,
                                                  Clinical_Trial_Profile__r.E_Consent_Configuration__c,Study_Site__r.E_Consent_Vendor__c,
                                                  Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id];
        
        Boolean result = CreateParticipantController.isCreateConsentEnabled(peList[0]);
        Test.stopTest();
    }
    
    @isTest
    static void testIsCreateConsentDisabled() {
        TestData td = new TestData();
        Test.startTest();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : [SELECT Id, Re_consent__c,Informed_Consent__c,ParticipantGUID__c FROM Participant_Enrollment__c WHERE Id = :td.pe.Id]) {
            pe.ParticipantGUID__c = 'testid';
            peList.add(pe);
        }
        update peList; 
        
        peList = [SELECT Id, Re_consent__c,Informed_Consent__c,ParticipantGUID__c, Clinical_Trial_Profile__r.StudyGUID__c,
                  Study_Site__c, Study_Site__r.SiteGuid__c, Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                  Study_Site__r.E_Consent_Vendor__c, Study_Site__r.E_Consent_Vendor__r.Name
                  FROM Participant_Enrollment__c WHERE Id = :td.pe.Id];
        
        Boolean result = CreateParticipantController.isConsentDisabled(peList[0]);        
        Test.stopTest();
    }    
    
    @isTest
    static void testisConsentVerificationApplicable(){
        TestData td = new TestData();
        Test.startTest();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : [SELECT Id,Informed_Consent__c,Re_consent__c, ParticipantGUID__c  FROM Participant_Enrollment__c WHERE Id = :td.pe.Id]) {
            pe.ParticipantGUID__c = 'testid123';
            peList.add(pe);
        }
        update peList; 
        peList = [Select Id,ParticipantGUID__c,Re_consent__c,Informed_Consent__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                  Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                  Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id];
        
        Boolean result = CreateParticipantController.isConsentVerificationApplicable(peList[0]);
        Test.stopTest();
    }
    
    @isTest
    static void testGetCreateConsentParams() {
        TestData td = new TestData();
        Test.startTest();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for (Participant_Enrollment__c pe : [SELECT Id, Re_consent__c, Informed_Consent__c FROM Participant_Enrollment__c WHERE Id = :td.pe.Id]) {
            pe.Re_consent__c = false;
            pe.Informed_Consent__c = false;
            peList.add(pe);
        }
        update peList; 
        
        peList = [SELECT Id, ParticipantGUID__c, SenttoCompleteConsent__c, Clinical_Trial_Profile__r.StudyGUID__c,
                  Study_Site__c, Study_Site__r.SiteGuid__c, Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                  Study_Site__r.E_Consent_Vendor__c, Study_Site__r.E_Consent_Vendor__r.Name
                  FROM Participant_Enrollment__c WHERE Id = :td.pe.Id];
        
        CreateParticipantController.Consentdetails result = CreateParticipantController.getCreateConsentParams(peList[0].Id);
        Test.stopTest();
        
        //System.assertNotEquals(true, result.isEnabled);
        //System.assertEquals(false, result.isDisabled);
        //System.assertEquals(peList[0].SenttoCompleteConsent__c, result.consentDate);
        //System.assertEquals(null, result, 'The consented date should be null when SenttoCompleteConsent__c is null');
        
    }
    
   @isTest
    static void testGetConsentParams() {
        TestData td = new TestData();
        Test.startTest();
        
        TriggerHandlerExecutor.bypassHandler(PatientDelegateTriggerHandler.class);
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        
       /* List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        
        Account piAccount = new Account(
            Name = 'PI Account'
        );
        insert piAccount;
        
        Contact piContact = new Contact(
            FirstName = 'PI',
            LastName = 'PI',
            Email = '04ipremail@gmtesstail.com',
            AccountId = piAccount.Id,
            Birthdate = Date.valueOf('1987-03-01')
        );
        insert piContact;
        
        Study_Site__c studySite = [select Id,Principal_Investigator__c,Site__c from Study_Site__c limit 1];
        Participant__c participant4 = new Participant__c(
            First_Name__c = 'PI',
            Last_Name__c = 'PI',
            Phone__c = '8343212',
            Email__c = '04ipremail@gmtesstail.com',
            Mailing_Country_Code__c = 'US',
            Mailing_State_Code__c = 'AL',
            Adult__c = true,
            Site__c = studySite.Site__c,
            Date_of_Birth__c = '1987-03-01',
            Contact__c = piContact.Id,
            Mailing_Zip_Postal_Code__c = '12345'
        );
        insert participant4;
        
        List<Participant_Enrollment__c> peList = [SELECT Id, Name, Participant_Contact__c FROM Participant_Enrollment__c WHERE Id = :td.pe.Id];
        for (Participant_Enrollment__c pe : peList) {
            pe.Participant__c = participant4.id;
            pe.Participant_Contact__c = piContact.Id;
        }
        update peList;   */  
        
        CompleteConsent__c config = new CompleteConsent__c();
        config.Base_Url__c = 'https://uat1-aacens-na.completeconsent.iqvia.com';
        config.Relative_Url__c = '/dashboard/remoteconsent/{SiteGuid}/patient/{ParticipantGuid}';
        insert config;
        
        User delegateUser = td.createPatientDelegate();
        system.runAs(delegateUser) {
            CreateParticipantController.getConsentParams();
        }
       
        Test.stopTest();
    }
   
    
}