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
        Contact hcpContact = [SELECT Id, HCP_Opt_In_Referral_Status_Emails__c FROM Contact WHERE Email = 'hcp@emil.com'];
        hcpContact.HCP_Opt_In_Referral_Status_Emails__c = true;
        Database.update(hcpContact);
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
    static void hcpDelegateWithParentTest() {
        TestData testData = new TestData();
        Contact hcpContact = [SELECT Id, HCP_Opt_In_Referral_Status_Emails__c FROM Contact WHERE Email = 'hcp@emil.com'];
        hcpContact.HCP_Opt_In_Referral_Status_Emails__c = true;
        Database.update(hcpContact);
        Test.startTest();
        System.runAs(testData.hcpUser) {
            MyTeamRemote.getInitData(CommunityService.USER_MODE_HCP, testData.hcpUser.ContactId);
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
    static void piDelegateWithParentTest() {
        TestData testData = new TestData();
       
        MyTeamRemote.MyTeamDetail detail;
        List<Contact> parentContact = [SELECT Id, Salutation FROM Contact WHERE Id=:testData.piUser.ContactId];
        if(parentContact!=NULL && !parentContact.isEmpty()){
            parentContact[0].Salutation = 'Mr';
            Database.update(parentContact);
        }
        System.runAs(testData.piUser) {
            Test.startTest();
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, testData.piUser.ContactId);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                MyTeamRemote.getContactData(
                    CommunityService.USER_MODE_PI,
                    'pi_delegate@emil.com',
                    testData.piUser.ContactId
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
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_1;
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
    static void getInitDataNegativeTest() {
        TestData testData = new TestData();
        Test.startTest();
        MyTeamRemote.MyTeamDetail detail;
        System.runAs(testData.piUser) {
            try{
                MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, 'invalidParentId');
            } catch (AuraHandledException e) {
                System.assertEquals('Script-thrown exception', e.getMessage());
            } 
        }
        Test.stopTest();
    }
    
    @IsTest
    static void piDelegateWithoutParentSalutationTest() {
        TestData testData = new TestData();
        
        MyTeamRemote.MyTeamDetail detail;
        List<Contact> parentContact = [SELECT Id, Salutation FROM Contact WHERE Id=:testData.piUser.ContactId];
        if(parentContact!=NULL && !parentContact.isEmpty()){
            parentContact[0].Salutation = null;
            Database.update(parentContact);
        }
        System.runAs(testData.piUser) {
            Test.startTest();
            MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, testData.piUser.ContactId);
            detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                MyTeamRemote.getContactData(
                    CommunityService.USER_MODE_PI,
                    'pi_delegate@emil.com',
                    testData.piUser.ContactId
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
            detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_1;
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
    static void piDelegateWithoutParentSalutationNegativeTest() {
        TestData testData = new TestData();
        Test.startTest();
        MyTeamRemote.MyTeamDetail detail;
        List<Contact> parentContact = [SELECT Id, Salutation FROM Contact WHERE Id=:testData.piUser.ContactId];
        try{
            System.runAs(testData.piUser) {
                MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, testData.piUser.ContactId);
                detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                    MyTeamRemote.getContactData(
                        CommunityService.USER_MODE_PARTICIPANT,
                        'pi_delegate@emil.com',
                        testData.piUser.ContactId
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
                detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_1;
              
            }
        }catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void piDelegateGetContactDataNegativeTest() {
        TestData.createPIDelegateUser();
        TestData testData = new TestData();
        Test.startTest();
        MyTeamRemote.MyTeamDetail detail;
        List<Contact> parentContact = [SELECT Id, Salutation FROM Contact WHERE Id=:testData.piUser.ContactId];
        try{
            System.runAs(testData.piDelUser) {
                MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, testData.piUser.ContactId);
                detail = (MyTeamRemote.MyTeamDetail) JSON.deserialize(
                    MyTeamRemote.getContactData(
                        CommunityService.USER_MODE_PARTICIPANT,
                        'pi_delegate@emil.com',
                        testData.piUser.ContactId
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
                detail.delegates[0].delegateTrials[0].siteLevels[0].delegateLevel = DelegateService.DELEGATE_LEVEL_1;
            }
        }catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
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
        Contact con = new Contact();
        MyTeamRemote.getMaxLength(con, new List<String>{'Id', 'Email', 'FirstName', 'LastName'});
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
            Boolean isExistingDelegate = MyTeamRemote.isExistingDelegate(JSON.serialize(c));
            System.assertEquals(false, isExistingDelegate);
        }
        Test.stopTest();
    }

    @isTest
    static void Test_savePatientDelegateExistingUser(){
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
            Contact c2 = [SELECT Id, FirstName, LastName, EMail FROM Contact WHERE Email='lol@l.com' LIMIT 1];
            MyTeamRemote.savePatientDelegate(JSON.serialize(c2));  
        }
        
        Test.stopTest();
    }

    @isTest
    static void Test_sendEmailNotificationWelcome(){
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
            
            Contact c2 = [SELECT Id, FirstName, LastName, EMail FROM Contact WHERE Email='lol@l.com' LIMIT 1];
			MyTeamRemote.sendEmailNotificationWelcome(c2);
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
    
    @isTest
    static void Test_DelegateWrapper2(){
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
            c2.FirstName = 'dummy2';
            c2.LastName = 'd2';
            c2.Email = 'lol@l2.com';
			MyTeamRemote.DelegateWrapper dw2 = new MyTeamRemote.DelegateWrapper();
            dw2.delegateContact = c2;
            
            Integer compareCheck;
            compareCheck = dw1.compareTo(dw2);
            System.assertEquals(1, compareCheck);
            compareCheck = dw2.compareTo(dw1);
            System.assertEquals(-1, compareCheck);
        }
        Test.stopTest();
    }
    
    @isTest
    static void Test_ParticipantDelegateWrapper(){
        TestData tstData = new TestData();
        User dataUser = tstData.createPatientDelegate();
        MyTeamRemote.MyTeamDetail detail;
        Test.startTest();
        System.runAs(dataUser) {
            Contact c1 = new Contact();
            c1.FirstName = 'dummy';
            c1.LastName = 'd';
            c1.Email = 'lol@l.com';
			MyTeamRemote.DelegateWrapper dw1 = new MyTeamRemote.DelegateWrapper();
            dw1.delegateContact = c1;

            Contact c2 = new Contact(Id=dataUser.ContactId);
			MyTeamRemote.DelegateWrapper dw2 = new MyTeamRemote.DelegateWrapper();
            dw2.delegateContact = c2;
            
            Integer compareCheck;
            compareCheck = dw1.compareTo(dw2);
            System.assertEquals(1, compareCheck);
            compareCheck = dw2.compareTo(dw1);
            System.assertEquals(-1, compareCheck);
        }
        Test.stopTest();
    }
    
    @isTest
    static void Test_DelegateLevelWrapper(){
        TestData tstData = new TestData();
        tstData.createPatientDelegate();
        Test.startTest();
        System.runAs(tstData.participantUser) {
			MyTeamRemote.DelegateLevelWrapper dw1 = new MyTeamRemote.DelegateLevelWrapper();
            dw1.delegateLevel = 'Test';
            dw1.entityName = 'entityNameTest';

			MyTeamRemote.DelegateLevelWrapper dw2 = new MyTeamRemote.DelegateLevelWrapper();
			dw2.delegateLevel = 'Test2';
            dw2.entityName = 'entityNameTest2';
            
            Integer compareCheck;
            compareCheck = dw1.compareTo(dw2);
            System.assertEquals(-1, compareCheck);
            compareCheck = dw2.compareTo(dw1);
            System.assertEquals(1, compareCheck);
            compareCheck = dw2.compareTo(dw2);
            System.assertEquals(0, compareCheck);
        }
        Test.stopTest();
    }
    
    @isTest
    static void Test_getDelegateParents(){
        TestData.createPIDelegateUser();
        TestData tstData = new TestData();
        MyTeamRemote.MyTeamDetail detail;
        List<Site_Staff__c> piStaffs = [
            SELECT
                Id,
                Study_Site__c,
                Study_Site__r.Principal_Investigator__c,
                Study_Site__r.Clinical_Trial_Profile__c,
                Delegate_Level__c,
                Clinical_Trial_Profile__c,
                Site_Contact__c,
                is_Invited__c
            FROM Site_Staff__c LIMIT 1];
        piStaffs[0].is_Invited__c = true;
        Database.update(piStaffs);
        Test.startTest();
        List<LabelValueItem> labelValueList = new List<LabelValueItem>();
        System.runAs(tstData.piDelUser) {
        try{
             MyTeamRemote.getInitData(CommunityService.USER_MODE_PI, tstData.piUser.ContactId);
             labelValueList = MyTeamRemote.getDelegateParents();
        }catch(Exception ex){}
        }
        Test.stopTest();
        System.assertEquals(0, labelValueList.size());
    }
    
    @isTest
    static void Test_TrialDelegateWrapper(){
        TestData tstData = new TestData();
        tstData.createPatientDelegate();
        Test.startTest();
        System.runAs(tstData.participantUser) {
			MyTeamRemote.TrialDelegateWrapper dw1 = new MyTeamRemote.TrialDelegateWrapper();
            dw1.trialName = 'Test';

			MyTeamRemote.TrialDelegateWrapper dw2 = new MyTeamRemote.TrialDelegateWrapper();
			dw2.trialName = 'Test2';
            
            Integer compareCheck;
            compareCheck = dw1.compareTo(dw2);
            System.assertEquals(-1, compareCheck);
            compareCheck = dw2.compareTo(dw1);
            System.assertEquals(1, compareCheck);
            compareCheck = dw2.compareTo(dw2);
            System.assertEquals(0, compareCheck);
        }
        Test.stopTest();
    }

}