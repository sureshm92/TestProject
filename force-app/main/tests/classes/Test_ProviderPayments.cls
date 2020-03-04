/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_ProviderPayments {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testOrientation() {
        TestData testData = new TestData();
        Test.startTest();
        testData.hcpEnrollment.Orientation_Date__c = Date.today();
        update testData.hcpEnrollment;
        Test.stopTest();
        List<Provider_Payment__c> providerPayments = [SELECT Id FROM Provider_Payment__c WHERE Activity__c =:ProviderPaymentsService.ACTIVITY_TYPE_ORIENTATION];
        System.assertEquals(1, providerPayments.size());
    }

    @IsTest
    static void testMRRn() {
        TestData testData = new TestData();
        Test.startTest();
        testData.pe.Medical_Record_Review_Completed_Date__c = Datetime.now();
        update testData.pe;
        Test.stopTest();
        List<Provider_Payment__c> providerPayments = [SELECT Id FROM Provider_Payment__c WHERE Activity__c =:ProviderPaymentsService.ACTIVITY_TYPE_MRR];
        System.assertEquals(1, providerPayments.size());
    }
}
