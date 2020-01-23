/**
 * Created by Nargiz Mamedova on 1/22/2020.
 */

@IsTest
private class Test_Action_GetCardDetails {
    @IsTest
    static void testExecute() {
        TestData.loadTestData();
        TestData testData = new TestData();
        Payment_Vendor__c pv = new Payment_Vendor__c(Payment_Vendor_Id__c = '12345', Name = 'Qiwi', Link_Vendor__c = 'https://qiwi.com/');
        insert pv;

        pv = [SELECT Id, Payment_Vendor_Id__c FROM Payment_Vendor__c];
        PaymentVendorSettings__c pvs = new PaymentVendorSettings__c(Payment_Vendor__c = pv.Id, Study_Site__c = testData.ss.Id);
        insert pvs;

        Test.startTest();
        Action_GetCardDetails action = new Action_GetCardDetails(pv.Payment_Vendor_Id__c, testData.participant);
        Test.setMock(HttpCalloutMock.class, new GetCardDetailsHttpCalloutMock());
        ActionExecutor.execute(action);
        Test.stopTest();

        Participant__c participant = [SELECT Id, Status__c, Balance__c, Pending_Payments__c FROM Participant__c];
        System.assertEquals(participant.Status__c, 'Active');
    }
}