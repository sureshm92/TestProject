@IsTest
public class Test_SMSDeliveryStatusTriggerHandler {
    @IsTest
    static void processDeliveryReceipt() {
        TestData.loadTestData();
        Test.startTest();
        List<SMS_Delivery_Status__e> ssmDeliveryStatus = new List<SMS_Delivery_Status__e>();
        SMSDeliveryStatusTriggerHandler.processDeliveryReceipt(ssmDeliveryStatus);
        Test.stopTest();
    }
}
