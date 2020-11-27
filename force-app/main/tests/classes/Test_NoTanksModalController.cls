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
        TestData td = new TestData();
        td.ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT;
        update td.ss;
        Test.startTest();
        System.runAs(td.hcpUser) {
            NoTanksModalController.deactivateTrial(
                td.ctp.Id,
                CommunityService.USER_MODE_HCP,
                td.ss.Id
            );
        }
        Test.stopTest();
        List<Study_Site__c> testStudySites = [
            SELECT Id, Override_PI_Referral_Status__c
            FROM Study_Site__c
            WHERE Id = :td.ss.Id
        ];
        System.assertEquals(
            StudySiteService.PI_S_DECLINED_ACCEPTANCE,
            testStudySites[0].Override_PI_Referral_Status__c
        );
    }

    @IsTest
    static void PITest() {
        TestData td = new TestData();
        td.ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT;
        update td.ss;
        Test.startTest();
        System.runAs(td.piUser) {
            NoTanksModalController.deactivateTrial(
                td.ctp.Id,
                CommunityService.USER_MODE_PI,
                td.ss.Id
            );
        }
        Test.stopTest();
        List<Study_Site__c> testStudySites = [
            SELECT Id, Override_PI_Referral_Status__c
            FROM Study_Site__c
            WHERE Id = :td.ss.Id
        ];
        System.assertEquals(
            StudySiteService.PI_S_DECLINED_ACCEPTANCE,
            testStudySites[0].Override_PI_Referral_Status__c
        );
    }

    @IsTest
    static void PITestNoSSId() {
        TestData td = new TestData();
        td.ss.Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT;
        update td.ss;
        Test.startTest();
        System.runAs(td.piUser) {
            NoTanksModalController.deactivateTrial(td.ctp.Id, CommunityService.USER_MODE_PI, null);
        }
        Test.stopTest();
        List<Study_Site__c> testStudySites = [
            SELECT Id, Override_PI_Referral_Status__c
            FROM Study_Site__c
            WHERE Id = :td.ss.Id
        ];
        System.assertEquals(
            StudySiteService.PI_S_DECLINED_ACCEPTANCE,
            testStudySites[0].Override_PI_Referral_Status__c
        );
    }
    @IsTest
    static void HCPTestNoSSId() {
        TestData td = new TestData();
        Test.startTest();
        System.runAs(td.hcpUser) {
            NoTanksModalController.deactivateTrial(td.ctp.Id, CommunityService.USER_MODE_HCP, null);
        }
        Test.stopTest();
        List<HCP_Enrollment__c> testHCPEs = [
            SELECT Id, Status__c
            FROM HCP_Enrollment__c
            WHERE Id = :td.hcpEnrollment.Id
        ];
        System.assertEquals(HCPEnrollmentService.HCP_S_DECLINE_ACTIVATION, testHCPEs[0].Status__c);
    }
}
