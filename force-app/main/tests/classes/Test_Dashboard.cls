/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_Dashboard {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void HCPTest() {
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_HCP, null,null,null,null);
            DashboardRemote.getParticipantData(CommunityService.USER_MODE_HCP, null,testDataInst.participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PITest() {
        TestData testDataInst = new TestData();
        TestData.createHCPEWaitingAcceptance();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, null, testDataInst.piContact.Id,testDataInst.ctp.Id,null);
            DashboardRemote.getParticipantData(CommunityService.USER_MODE_PI, null,testDataInst.participant.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIContactAttemptedTest() {
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_CONTACT_ATTEMPTED);
        Test.startTest();
        System.runAs(testDataInst.piUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, null,testDataInst.piContact.Id,testDataInst.ctp.Id,null);
        }
        Test.stopTest();
    }

    @IsTest
    static void PIDelegateTest() {
        TestData.createPIDelegateUser();
        TestData testDataInst = new TestData();
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_ELIGIBILITY_PASSED);
        testDataInst.updatePEStatusThroughHistory(PEStatusState.PE_STATUS_SCREENING_PASSED);
        Test.startTest();
        System.runAs(testDataInst.piDelUser) {
            DashboardRemote.getInitData(CommunityService.USER_MODE_PI, testDataInst.ss.Principal_Investigator__c,testDataInst.ss.Principal_Investigator__c,testDataInst.ctp.Id,null);
            DashboardRemote.getParticipantData(CommunityService.USER_MODE_PI, testDataInst.ss.Principal_Investigator__c,testDataInst.participant.Id);
        }
        Test.stopTest();
    }
}