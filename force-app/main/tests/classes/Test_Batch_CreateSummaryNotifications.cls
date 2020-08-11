/**
 * Created by Igor Malyuta on 16.09.2019.
 */

@IsTest
private class Test_Batch_CreateSummaryNotifications {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testBehavior() {
        TriggerHandlerExecutor.bypassHandler(NotificationTriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);

        ContentVersion contentVersion = new ContentVersion(
                LanguageCode__c = 'en_US',
                Title = 'en_US',
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
        Id docId = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1].ContentDocumentId;
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

        testData.ss.Approved_Lng__c = 'en_US';
        update testData.ss;

        testData.pe.Participant_Contact__r.Participant_Opt_In_Status_Emails__c = true;
        update testData.pe.Participant_Contact__r;

        testData.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS);

        Test.startTest();
        List<Res_study__c> resStudies = [
                SELECT
                        Active_After_Days__c,
                        Active_On_Status__c,
                        Clinical_Trial_Profile__c,
                        Expires_After_Days__c,
                        Expires_On_Status__c,
                        Id,
                        Notify_On_Availability__c,
                        Resource__c,
                        Resource__r.Content_Type__c,
                        Resource__r.Language__c,
                        Visible_In_Alumni__c,
                        Visible_To_Delegates__c,
                        Visible_To_Participant__c
                FROM Res_study__c
                WHERE Notify_On_Availability__c = TRUE
                AND Visible_To_Participant__c = TRUE
                AND Resource__r.Content_Type__c = 'Study_Document'
        ];

        new Batch_CreateSummaryNotifications().execute(null, resStudies);
        Test.stopTest();

        Contact updatedContact = [
                SELECT Id, Resource_Notifications__c
                FROM Contact
                WHERE Id = :testData.pe.Participant_Contact__c
        ];

        System.assertEquals(resource.Id, updatedContact.Resource_Notifications__c);
    }
}