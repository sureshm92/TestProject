@IsTest
public class Test_ResourceBatchDeletion {
  @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void resourceBatchDeletionReview_Test() {
    
        List<Study_Site__c> testStudySites = [
            SELECT Id, Clinical_Trial_Profile__c,Principal_Investigator__c, Clinical_Trial_Profile__r.Name 
            FROM Study_Site__c 
            LIMIT 1
        ];
        
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContentDocumentLinkTriggerHandler.class,
            TriggerOperation.AFTER_INSERT
        );
        ContentVersion contentVersion = new ContentVersion(
            LanguageCode__c = 'en_US',
            Title = 'Test Content',
            PathOnClient = 'Irregular verbs.pdf',
            VersionData = EncodingUtil.base64Decode('fdsgg5465w')
        );
        insert contentVersion;

        Resource__c resource = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'TestRes'
        );
        insert resource;
        Id docId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Test Content'
            LIMIT 1
        ]
        .ContentDocumentId;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = resource.Id
        );
        insert contentDocumentLink;
        
        Study_Closure__c studyClosure =  new Study_Closure__c(
            Clinical_Trial_Profile_Id__c = testStudySites[0].Clinical_Trial_Profile__c, 
            Clinical_Trial_Profile_Name__c = testStudySites[0].Clinical_Trial_Profile__r.Name
        );
        insert studyClosure;

        TestData testData = new TestData();
        Res_study__c resStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = resource.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resStudy;
        
        Test.startTest();
            Database.executeBatch(new ResourceBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c),5);
        Test.stopTest();
        
        List<ContentDocumentLink> contentDocLinkList = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :studyClosure.Id
        ];
        System.assertEquals(3, contentDocLinkList.size());
    }
    
    @IsTest
    static void resourceBatchDeletion_Test() {
    
        List<Study_Site__c> testStudySites = [
            SELECT Id, Clinical_Trial_Profile__c, Principal_Investigator__c 
            FROM Study_Site__c 
            LIMIT 1
        ];
        
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
        );
        TriggerHandlerExecutor.bypassHandler(
            ContentDocumentLinkTriggerHandler.class,
            TriggerOperation.AFTER_INSERT
        );
        ContentVersion contentVersion = new ContentVersion(
            LanguageCode__c = 'en_US',
            Title = 'Test Content',
            PathOnClient = 'Irregular verbs.pdf',
            VersionData = EncodingUtil.base64Decode('fdsgg5465w')
        );
        insert contentVersion;

        Resource__c resource = new Resource__c(
            Content_Type__c = 'Study_Document',
            Description__c = 'testBehavior',
            document_type__c = 'Document',
            Title__c = 'TestRes'
        );
        insert resource;
        Id docId = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Title = 'Test Content'
            LIMIT 1
        ]
        .ContentDocumentId;
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            ContentDocumentId = docId,
            LinkedEntityId = resource.Id
        );
        insert contentDocumentLink;

        TestData testData = new TestData();
        Res_study__c resStudy = new Res_study__c(
            Active_After_Days__c = 0.00,
            Active_On_Status__c = PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Expires_After_Days__c = 5,
            Expires_On_Status__c = PEStatusState.PE_STATUS_TREATMENT_PERIOD_STARTED,
            Notify_On_Availability__c = true,
            Resource__c = resource.Id,
            Visible_In_Alumni__c = false,
            Visible_To_Delegates__c = true,
            Visible_To_Participant__c = true
        );
        insert resStudy;
        
        Test.startTest();
            Database.executeBatch(new ResourceBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c, true),5);
        Test.stopTest();
        
        List<Res_study__c> resourseList = [
            SELECT Id FROM Res_study__c 
            WHERE Clinical_Trial_Profile__c = :testStudySites[0].Clinical_Trial_Profile__c
        ];
        System.assertEquals(0,resourseList.size());
        
    }
    
    @IsTest
    static void resourceBatchDeletionFalse_Test() {
        
        List<Study_Site__c> testStudySites = [
            SELECT Id, Clinical_Trial_Profile__c,Principal_Investigator__c, Clinical_Trial_Profile__r.Name 
            FROM Study_Site__c 
            LIMIT 1
        ];
        
        Study_Closure__c studyClosure =  new Study_Closure__c(
            Clinical_Trial_Profile_Id__c = testStudySites[0].Clinical_Trial_Profile__c, 
            Clinical_Trial_Profile_Name__c = testStudySites[0].Clinical_Trial_Profile__r.Name
        );
        insert studyClosure;
        
        Test.startTest();
            Database.executeBatch(new ResourceBatchDeletion(null),5);
        Test.stopTest();
        
        List<ContentDocumentLink> contentDocLinkList = [
            SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :studyClosure.Id
        ];
        System.assertEquals(0, contentDocLinkList.size());
    }
}