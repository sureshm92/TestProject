@isTest
public class Test_Batch_CreateECOASubjectEvents {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
        
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctp.Study_GUID__c = 'testguid1234';
        ctp.ECOA_Is_Avaialble__c = true;
        ctp.Study_Version_GUID__c = 'abc123';
        update ctp;
        ECOA_Study_Schedule__c obj1 = new ECOA_Study_Schedule__c();
        obj1.Clinical_Trial_Profile__c = ctp.id;
        obj1.ClinroRuleSetGuid__c = 'test123';
        obj1.EproRuleSetGuid__c = 'eprorule12';
        insert obj1;
    }

    @isTest
    private static void Batch_CreateECOASubjectEvents() {
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class);
        TestData testData = new TestData();
        Test.setMock(HttpCalloutMock.class, new Test_ECOAServiceMockCallout());
        Clinical_Trial_Profile__c ctp = [
            SELECT id, Study_GUID__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        Participant_Enrollment__c pe = [
            SELECT id, Subject_GUID__c, Participant_Status__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__c = :ctp.id
            LIMIT 1
        ];
        Test.startTest();
        pe.Subject_GUID__c = '11111';
        pe.Participant_Status__c = 'Enrollment Success';
        update pe;

        Study_Site__c ss = [SELECT id FROM Study_Site__c LIMIT 1];
        ss.ECOA_Site_Guid__c = 'ecosite123';
        update ss;
        
        
        Set<Id> peId = new Set<Id>{pe.Id};
        DataBase.executeBatch(new Batch_CreateECOASubjectEvents(peId));
        Test.stopTest();
    }
}