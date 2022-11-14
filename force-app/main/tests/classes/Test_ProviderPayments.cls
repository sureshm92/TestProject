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
        List<Provider_Payment__c> providerPayments = [
            SELECT Id
            FROM Provider_Payment__c
            WHERE Activity__c = :ProviderPaymentsService.ACTIVITY_TYPE_ORIENTATION
        ];
        System.assertEquals(1, providerPayments.size());
    }

    @IsTest
    static void testMRRn() {
        TestData testData = new TestData();
        List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
        screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = testData.ctp.Id,
            Survey_Name__c = 'Prescreener'
        ));

        insert screenerList;

        Participant_PrescreenerResponse__c response = new Participant_PrescreenerResponse__c(
            PreScreener_Survey__c = screenerList[0].Id,
            Screener_Response__c = 'Test Response',
            MRR__c = true,
            Completed_Date__c = system.now(),
            Participant_enrollment__c = testData.pe.Id,
            Status__c = 'Pass'
        );
        
        Test.startTest();
            insert response;
        Test.stopTest();
        List<Provider_Payment__c> providerPayments = [
            SELECT Id
            FROM Provider_Payment__c
            WHERE Activity__c = :ProviderPaymentsService.ACTIVITY_TYPE_MRR
        ];
        System.assertEquals(1, providerPayments.size());
    }
}
