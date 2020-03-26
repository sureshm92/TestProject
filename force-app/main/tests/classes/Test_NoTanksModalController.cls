/**
 * Created by Andrii Kryvolap.
 */


@IsTest(IsParallel=false)
private class Test_NoTanksModalController {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void HCPTest() {
        TestData testDataInst = new TestData();
        testDataInst.ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT;
        update testDataInst.ss;
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            NoTanksModalController.deactivateTrial(testDataInst.ctp.Id, CommunityService.USER_MODE_HCP, testDataInst.ss.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PITest() {
        TestData testDataInst = new TestData();
        testDataInst.ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT;
        update testDataInst.ss;
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            NoTanksModalController.deactivateTrial(testDataInst.ctp.Id, CommunityService.USER_MODE_PI, testDataInst.ss.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PITestNoSSId() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            NoTanksModalController.deactivateTrial(testDataInst.ctp.Id, CommunityService.USER_MODE_PI, null);
        }
        Test.stopTest();
    }
    @IsTest
    static void HCPTestNoSSId() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            NoTanksModalController.deactivateTrial(testDataInst.ctp.Id, CommunityService.USER_MODE_HCP, null);
        }
        Test.stopTest();
    }
}