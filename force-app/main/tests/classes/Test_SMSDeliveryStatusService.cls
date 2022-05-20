@IsTest
public class Test_SMSDeliveryStatusService {
    @IsTest
    static void updateGlobalFlag() {
        TestData.loadTestData();
        Test.startTest();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, String> notificationIdStatusMap = new Map<Id, String>();
        Map<Id, Boolean> pfLevelSMSContIdDelStatusMap = new Map<Id, Boolean>();
        SMS_Delivery_Status__e delReceipt;
        SMSDeliveryStatusService.updateGlobalFlag(contactIdSet);
        SMSDeliveryStatusService.updateDeliveryStatusFlag(notificationIdStatusMap);
        SMSDeliveryStatusService.createIntegrationLog(delReceipt);
        SMSDeliveryStatusService.updatePlatFormLevelDelRecFlag(pfLevelSMSContIdDelStatusMap);
        SMSDeliveryStatusService.updateStudyLevelDelRecFlag(pfLevelSMSContIdDelStatusMap);
        Test.stopTest();
    }
}
