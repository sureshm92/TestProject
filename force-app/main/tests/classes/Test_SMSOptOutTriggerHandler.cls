@IsTest
public class Test_SMSOptOutTriggerHandler {
    @IsTest
    static void updateGlobalFlag() {
        TestData.loadTestData();
        Test.startTest();
        List<SMS_Opt_Out__e> smsOptOutPEventList = new List<SMS_Opt_Out__e>();
        SMSOptOutTriggerHandler.optOutForSMS(smsOptOutPEventList);
        Test.stopTest();
    }
}
