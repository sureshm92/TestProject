/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_SiteStaffTableRemote {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testGetInitData() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            SiteStaffTableRemote.InitData initData = SiteStaffTableRemote.getInitData(testDataInst.hcpEnrollment.Study_Site__c);
            System.assertEquals(initData.viewMode, 'Disabled');
        }
        Test.stopTest();
    }
    @IsTest
    static void testCreateInitData() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            SiteStaffTableRemote.InitData initData = SiteStaffTableRemote.createInitData(testDataInst.hcpEnrollment.Study_Site__c, 'Edit');
            System.assertEquals(initData.viewMode, 'Edit');
            System.assertEquals(initData.inInvitationActiveStatus, true);
            System.assertEquals(initData.siteStaffMembers.size(), 2);
        }
        Test.stopTest();
    }
    @IsTest
    static void testInviteUser() {
        TestData testDataInst = new TestData();
        Test.startTest();
        System.runAs(testDataInst.hcpUser) {
            SiteStaffTableRemote.InitData initData = SiteStaffTableRemote.createInitData(testDataInst.hcpEnrollment.Study_Site__c, 'Edit');
            Datetime timeStamp = Datetime.now();
            SiteStaffTableRemote.inviteStaffMember(initData.siteStaffMembers[1].staffContact.Id,testDataInst.hcpEnrollment.Study_Site__c);
            List<Action__c> pendingActions = [SELECT Id, Body__c, Status__c, CreatedDate FROM Action__c WHERE Type__c = 'Action_AssignContactPermissions' AND CreatedDate >= :timeStamp];
            System.debug(pendingActions);
            System.assertEquals(1, pendingActions.size());
        }
        Test.stopTest();
    }
}
