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
            RP_Delegate_Relationship__c rpDelegate = new RP_Delegate_Relationship__c(
        Referring_Provider__c = hcpContact.Id,
        Delegate_Access_Level__c = DelegateService.DELEGATE_LEVEL_1,
        Delegate__c = hcpContact.id
        );
            MyTeamRemote.MyTeamDetail detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                MyTeamRemote.getContactData(
                    CommunityService.USER_MODE_HCP,
                    'hcp_delegate@emil.com',
                    null
                ),
                MyTeamRemote.MyTeamDetail.class
            );
            detail.delegates[0].trialLevel.delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(
                CommunityService.USER_MODE_HCP,
                JSON.serialize(detail.delegates[0]),
                hcpContact.Id
            );
            detail.delegates[0].trialLevel.delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(
                CommunityService.USER_MODE_HCP,
                JSON.serialize(detail.delegates[0]),
                hcpContact.Id
            );
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                MyTeamRemote.getContactData(
                    CommunityService.USER_MODE_HCP,
                    'hcp_delegate_new@emil.com',
                    null
                ),
                MyTeamRemote.MyTeamDetail.class
            );
            detail.delegates[0].trialLevel.delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New HCP Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New HCP Delegate';
            MyTeamRemote.saveDelegateLevelChanges(
                CommunityService.USER_MODE_HCP,
                JSON.serialize(detail.delegates[0]),
                hcpContact.Id
            );
            MyTeamRemote.sendEmailNotification(hcpContact ,'HCP', new Map<String, List<Id>>());
            MyTeamRemote.sendEmailNotification(hcpContact ,'Participant', new Map<String, List<Id>>());
            MyTeamRemote.sendEmailNotification(hcpContact ,'PI', new Map<String, List<Id>>());
        }
        
        Test.stopTest();
        RP_Delegate_Relationship__c testHcpRelationship = [
            SELECT Id, Delegate_Access_Level__c, Delegate__r.FirstName, Delegate__r.LastName
            FROM RP_Delegate_Relationship__c
            WHERE Referring_Provider__c = :hcpContact.Id
        ];
        System.assertEquals(
            DelegateService.DELEGATE_LEVEL_2,
            testHcpRelationship.Delegate_Access_Level__c
        );
        System.assertEquals('Test New HCP Delegate', testHcpRelationship.Delegate__r.FirstName);
        System.assertEquals('Test New HCP Delegate', testHcpRelationship.Delegate__r.LastName);
    }
    
    

    @IsTest
    static void piDelegateTest() {
        TestData testData = new TestData();
        Test.startTest();
        MyTeamRemote.MyTeamDetail detail;
        System.runAs(testData.piUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, null);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                MyTeamRemote.getContactData(
                    CommunityService.USER_MODE_PI,
                    'pi_delegate@emil.com',
                    null
                ),
                MyTeamRemote.MyTeamDetail.class
            );
            detail.delegates[0]
                .delegateTrials[0]
                .siteLevels[0]
                .delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            MyTeamRemote.saveDelegateLevelChanges(
                CommunityService.USER_MODE_PI,
                JSON.serialize(detail.delegates[0]),
                null
            );
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = '';
            MyTeamRemote.saveDelegateLevelChanges(
                CommunityService.USER_MODE_PI,
                JSON.serialize(detail.delegates[0]),
                null
            );
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                MyTeamRemote.getContactData(
                    CommunityService.USER_MODE_PI,
                    'pi_delegate_new@emil.com',
                    null
                ),
                MyTeamRemote.MyTeamDetail.class
            );
            detail.delegates[0]
                .delegateTrials[0]
                .siteLevels[0]
                .delegateLevel = DelegateService.DELEGATE_LEVEL_2;
            detail.delegates[0].delegateContact.LastName = 'Test New PI Delegate';
            detail.delegates[0].delegateContact.FirstName = 'Test New PI Delegate';
            MyTeamRemote.saveDelegateLevelChanges(
                CommunityService.USER_MODE_PI,
                JSON.serialize(detail.delegates[0]),
                null
            );
        }
        Test.stopTest();
        Site_Staff__c testPiDel = [
            SELECT
                Id,
                Delegate_Level__c,
                Site_Contact__r.Email,
                Site_Contact__r.FirstName,
                Site_Contact__r.LastName
            FROM Site_Staff__c
            WHERE Site_Contact__r.Email = :detail.delegates[0].delegateContact.Email
        ];
        System.assertEquals(DelegateService.DELEGATE_LEVEL_2, testPiDel.Delegate_Level__c);
        System.assertEquals('Test New PI Delegate', testPiDel.Site_Contact__r.FirstName);
        System.assertEquals('Test New PI Delegate', testPiDel.Site_Contact__r.LastName);
    }

    @IsTest
    static void participantDelegateTest() {
        TestData tstData = new TestData();
        tstData.createPatientDelegate();
        MyTeamRemote.MyTeamDetail detail;
        Test.startTest();
        System.runAs(tstData.participantUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PARTICIPANT, null);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                MyTeamRemote.getContactData(
                    CommunityService.USER_MODE_PARTICIPANT,
                    'jsmith@somemail.com',
                    null
                ),
                MyTeamRemote.MyTeamDetail.class
            );
        }
        Test.stopTest();
        System.assert(detail.hasStudies);
        System.assertEquals(tstData.participant.Contact__c, detail.currentUserContactId);
        System.assertEquals('jsmith@somemail.com', detail.delegates[0].delegateContact.Email);
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
        result = MyTeamRemote.doCreateUser(dlw, 'PI');
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
        result = MyTeamRemote.doCreateUser(dlw, 'PI');
        Test.stopTest();
        System.assertEquals(false, result);
    }
    
    @isTest
    static void Test_savePatientDelegate(){
        TestData tstData = new TestData();
        tstData.createPatientDelegate();
        MyTeamRemote.MyTeamDetail detail;
        Test.startTest();
        System.runAs(tstData.participantUser) {
            Contact c = new Contact();
            c.FirstName = 'dummy';
            c.LastName = 'd';
            c.Email = 'lol@l.com';
            MyTeamRemote.savePatientDelegate(JSON.serialize(c));
        }
        Test.stopTest();
    }

    @isTest
    static void Test_DelegateWrapper(){
        TestData tstData = new TestData();
        tstData.createPatientDelegate();
        MyTeamRemote.MyTeamDetail detail;
        Test.startTest();
        System.runAs(tstData.participantUser) {
            Contact c1 = new Contact();
            c1.FirstName = 'dummy';
            c1.LastName = 'd';
            c1.Email = 'lol@l.com';
			MyTeamRemote.DelegateWrapper dw1 = new MyTeamRemote.DelegateWrapper();
            dw1.delegateContact = c1;
            
            Contact c2 = new Contact();
            c2.FirstName = 'dummy';
            c2.LastName = 'd';
            c2.Email = 'lol@l.com';
			MyTeamRemote.DelegateWrapper dw2 = new MyTeamRemote.DelegateWrapper();
            dw2.delegateContact = c2;
            
            List<MyTeamRemote.DelegateWrapper> dwList = new List<MyTeamRemote.DelegateWrapper>();
            dwList.add(dw1);
            dwList.add(dw2);
            dwList.sort();
        }
        Test.stopTest();
    }

}