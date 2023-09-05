@isTest
public class Test_CreateConsentIntegration {
    @TestSetup
    static void init(){
        TriggerHandlerExecutor.bypassHandler(
                    ParticipantEnrollmentSHTriggerHandler.CreateJanssenNotification.afterUpdate.class
                );
         
		TriggerHandlerExecutor.execute(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
    TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.createPIUserOrSendNotification.class
        );
        TriggerHandlerExecutor.bypassHandler(
            StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.afterInsert.class
        );
		TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class
		);
	 
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
        
        List<Participant_Enrollment__c> peList = [Select Id,DocumentCollectionName__c,DocumentCollectionId__c,DocumentCollectionTitle__c,ParticipantGUID__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                                  Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                                                  Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id];
        for (Participant_Enrollment__c peobj : peList) {
            peobj.Participant__c = td.participant.id;
            peobj.Id = td.pe.Id;
            peobj.Study_Site__c = ssList[0].Id;  
            peobj.Clinical_Trial_Profile__c = ctpList[0].id;
            peobj.DocumentCollectionTitle__c = 'test';
            peobj.DocumentCollectionName__c = 'testEng';
        }
        update peList;
    }
    
   @isTest static void testDocumentCollectionResponse() {
        TestData td = new TestData();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        MulesoftToken__c setting = new MulesoftToken__c();
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
        CreateConsentIntegration.ResponseWrapper docCollections = new CreateConsentIntegration.ResponseWrapper();
        
        CreateConsentIntegration.documentCollectionResponse(ctpList[0].StudyGUID__c,ssList[0].SiteGuid__c,accessToken);
        Test.stopTest();
        
    }
    
    static testMethod void testCreateParticipant() {
        TestData td = new TestData();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe :[Select Id,Name,DocumentCollectionName__c,DocumentCollectionId__c,DocumentCollectionTitle__c,ParticipantGUID__c,Re_consent__c,Informed_Consent__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                           Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                                           Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id]){
                                               pe.ParticipantGUID__c='test';
                                               peList.add(pe);
                                           }
        update peList;
        
        Test.startTest();
        CreateConsentIntegration.statusInfo info =  new CreateConsentIntegration.statusInfo();
        
        Test.setMock(HttpCalloutMock.class, new Mock_MulesoftIntegrationApi());
        String accessToken = MulesoftIntegrationApi.getAccessToken('Test');
        Map<String, CreateConsentIntegration.statusInfo> result = CreateConsentIntegration.createParticipant(peList, accessToken);
        Test.stopTest();
    }
    
    static testMethod void testCreateParticipantWithError() {
        List<Participant_Enrollment__c> enrollmentList = new List<Participant_Enrollment__c>();        
         MulesoftToken__c setting = new MulesoftToken__c();
        setting.Name = 'Test';
        setting.Named_Credentials_Name__c = 'Testerror';
        setting.Expiration_Date__c = DateTime.now().addHours(1);
        insert setting;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Mock_MulesoftIntegrationApi());
        String accessToken = MulesoftIntegrationApi.getAccessToken('Test');
        Map<String, CreateConsentIntegration.statusInfo> result = CreateConsentIntegration.createParticipant(enrollmentList, accessToken);
        
        Test.stopTest();        
    }
    
    @isTest
    static void testUpdateparticipantEnrollments() {
        
        TestData td = new TestData();
        Test.startTest();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe :[Select Id,Name,DocumentCollectionName__c,DocumentCollectionId__c,DocumentCollectionTitle__c,ParticipantGUID__c,Re_consent__c,Informed_Consent__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                           Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                                           Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id]){
                                               pe.ParticipantGUID__c='test';
                                               peList.add(pe);
                                           }
        update peList;
        
        Map<String, CreateConsentIntegration.ResponseWrapper> responseMap = new Map<String, CreateConsentIntegration.ResponseWrapper>();
        if (!peList.isEmpty()) {
            CreateConsentIntegration.ResponseWrapper response1 = new CreateConsentIntegration.ResponseWrapper();
            response1.participantId = td.participant.id;
            responseMap.put(peList[0].Name, response1);
            
            CreateConsentIntegration.updateparticipantEnrollments(peList, responseMap);
            Test.stopTest();
        }
    }
    
    @isTest
    static void testCreateParticipantRequest() {
        TestData td = new TestData();
        CreateConsentIntegration.bypassParticipantEnrollmentTrigger();
        List<Participant_Enrollment__c> peList = new List<Participant_Enrollment__c>();
        for(Participant_Enrollment__c pe :[Select Id,Name,DocumentCollectionName__c,DocumentCollectionId__c,DocumentCollectionTitle__c,ParticipantGUID__c,Re_consent__c,Informed_Consent__c,SenttoCompleteConsent__c,Clinical_Trial_Profile__r.StudyGUID__c,
                                           Study_Site__c,Study_Site__r.SiteGuid__c,Clinical_Trial_Profile__r.E_Consent_Configuration__c,
                                           Study_Site__r.E_Consent_Vendor__c,Study_Site__r.E_Consent_Vendor__r.Name from Participant_Enrollment__c where Id=: td.pe.Id]){
                                               pe.ParticipantGUID__c='test';
                                               peList.add(pe);
                                           }
        update peList;
        Test.startTest();
        List<CreateConsentIntegration.RequestWrapper> requests = CreateConsentIntegration.createParticipantRequest(peList);
        Test.stopTest();
    }

}