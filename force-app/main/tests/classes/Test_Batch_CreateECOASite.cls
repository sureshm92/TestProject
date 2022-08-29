@IsTest
private class Test_Batch_CreateECOASite {
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
        ctp.Study_GUID__c = 'testguid123';
        ctp.ECOA_Is_Avaialble__c = true;
        update ctp;
        ECOA_Study_Schedule__c obj1 = new ECOA_Study_Schedule__c();
        obj1.Clinical_Trial_Profile__c = ctp.id;
        obj1.ClinroRuleSetGuid__c = 'test123';
        obj1.EproRuleSetGuid__c = 'eprorule12';
        insert obj1;
    }

    @isTest
    static void ecoaTest() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_ECOAServiceMockCallout());

        Batch_CreateECOASite obj1 = new Batch_CreateECOASite();
        DataBase.executeBatch(obj1);
        obj1.getRecommendedRelaunchInterval();
        obj1.getRecommendedScopeSize();
        obj1.getBatchDescription();

        Test.StopTest();
    }
}