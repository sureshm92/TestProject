@IsTest(IsParallel=false)
private class Test_PPNewRestrictedSourceConfigCon {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @IsTest
    static void testRestrictedSourceConfigData() {
        TestData testData = new TestData();
        Test.startTest();
        testData.ctp.Study_Sponsor__c = 'Janseen';
        update testData.ctp; 

        Restricted_Source_Config__c restrictedRecrd = new Restricted_Source_Config__c();
        restrictedRecrd.study__c = testData.ctp.Id;
        restrictedRecrd.Sponsor__c = testData.ctp.Study_Sponsor__c;
        insert restrictedRecrd;
        ppNewRestrictedSourceConfigCon.getRestrictedSourceConfigData(testData.ctp.Id);
        ppNewRestrictedSourceConfigCon.getRestrictedSourceConfigRecord(testData.ctp.Id);
        Test.stopTest();
        //Assert.isTrue(1, restrictedRecrd.size());
    }
}