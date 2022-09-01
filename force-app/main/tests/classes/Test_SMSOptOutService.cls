@IsTest
private class Test_SMSOptOutService {
    @testSetup
    static void setup() {
        TestData.loadTestData();
    }
    @IsTest
    static void testProcessOptOUTForSMS() {
        Test.startTest();
        TestData testData = new TestData();
        Set<String> messageIdSet = new Set<String>();
        Set<Id> notificationIdSet = new Set<Id>();
        Map<Id, String> participantContactSponsorMap = new Map<Id, String>();
        Set<Id> recipientId = new Set<Id>();
        SMS_Opt_Out__e smsOptOut;
        SMSOptOutService.processOptOUTForSMS(messageIdSet);
        SMSOptOutService.getSendResults(messageIdSet);
        SMSOptOutService.getNotifications(notificationIdSet);
        SMSOptOutService.processPlatFormLevelOptOut(recipientId);
        SMSOptOutService.processStudyLevelOptOut(participantContactSponsorMap);
        SMSOptOutService.createIntegrationLog(smsOptOut);
        Test.stopTest();
    }
}
