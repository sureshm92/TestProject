/**
 * Created by Andrii Kryvolap.
 */

@IsTest(IsParallel=false)
private class Test_MyTeamRemote {

    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }

    @IsTest
    static void hcpDelegateTest() {
        TestData testData = new TestData();
        Contact hcpContact = [SELECT Id FROM Contact WHERE Email = 'hcp@emil.com'];
        Test.startTest();
        System.runAs(testData.hcpUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_HCP, null);
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_HCP, 'hcp_delegate@emil.com', null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevel.delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]),hcpContact.Id);
            detail.delegates[0].trialLevel.delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]),hcpContact.Id);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_HCP, 'hcp_delegate_new@emil.com',null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].trialLevel.delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New HCP Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New HCP Delegate';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_HCP, JSON.serialize(detail.delegates[0]), hcpContact.Id);
        }
        Test.stopTest();
    }

    @IsTest
    static void piDelegateTest() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, null);
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_PI, 'pi_delegate@emil.com', null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]), null);
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]), null);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_PI, 'pi_delegate_new@emil.com', null), MyTeamRemote.MyTeamDetail.class);
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New PI Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New PI Delegate';
            MyTeamRemote.saveDelegateLevelChanges(CommunityService.USER_MODE_PI, JSON.serialize(detail.delegates[0]), null);
        }
        Test.stopTest();
    }

    @IsTest
    static void participantDelegateTest() {
        TestData tstData = new TestData();
        tstData.createPatientDelegate();
        Test.startTest();
        System.runAs(tstData.participantUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PARTICIPANT, null);
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(MyTeamRemote.getContactData(CommunityService.USER_MODE_PARTICIPANT, 'jsmith@somemail.com', null), MyTeamRemote.MyTeamDetail.class);
        }
        Test.stopTest();
    }

    @IsTest
    static void testDoCreateUserOn() {
        List<MyTeamRemote.TrialDelegateWrapper> dlw = new List<MyTeamRemote.TrialDelegateWrapper>();
        MyTeamRemote.TrialDelegateWrapper wrap = new MyTeamRemote.TrialDelegateWrapper();
        MyTeamRemote.DelegateLevelWrapper wrap2 = new MyTeamRemote.DelegateLevelWrapper();

        wrap.trialName = 'Test01';
        wrap2.delegateLevel = 'Level 1';
        wrap2.ReferralStatus = 'Accepted';
        wrap.siteLevels.add(wrap2);

        dlw.add(wrap);
        Boolean result = false;
        Test.startTest();
            result = MyTeamRemote.doCreateUser(dlw);
        Test.stopTest();
        System.assertEquals(true, result);
    }
    @IsTest
    static void testDoCreateUserOff() {
        List<MyTeamRemote.TrialDelegateWrapper> dlw = new List<MyTeamRemote.TrialDelegateWrapper>();
        MyTeamRemote.TrialDelegateWrapper wrap = new MyTeamRemote.TrialDelegateWrapper();
        MyTeamRemote.DelegateLevelWrapper wrap2 = new MyTeamRemote.DelegateLevelWrapper();

        wrap.trialName = 'Test01';
        wrap2.delegateLevel = 'Level 1';
        wrap2.ReferralStatus = 'Invitation Sent';
        wrap.siteLevels.add(wrap2);

        dlw.add(wrap);
        Boolean result = false;
        Test.startTest();
        result = MyTeamRemote.doCreateUser(dlw);
        Test.stopTest();
        System.assertEquals(false, result);
    }
}
