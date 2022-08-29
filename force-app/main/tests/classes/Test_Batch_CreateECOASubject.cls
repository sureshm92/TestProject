@IsTest
private class Test_Batch_CreateECOASubject {
    @testSetup
    static void setUp() {
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
    @IsTest
    static void testBehavior() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_ECOAServiceMockCallout());
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.class);

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
        pe.Subject_GUID__c = null;
        pe.Participant_Status__c = 'Enrollment Success';
        update pe;

        Study_Site__c ss = [SELECT id FROM Study_Site__c LIMIT 1];
        ss.ECOA_Site_Guid__c = 'ecosite123';
        update ss;

        Batch_CreateECOASubject obj = new Batch_CreateECOASubject();
        DataBase.executeBatch(obj);

        obj.getBatchDescription();
        obj.getType();
        obj.getRecommendedRelaunchInterval();
        obj.getRecommendedScopeSize();
        Test.stopTest();
    }
}