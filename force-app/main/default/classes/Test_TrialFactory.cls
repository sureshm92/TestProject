@IsTest(IsParallel=false)
private class Test_TrialFactory {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }

    @IsTest
    static void basePITest() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.piUser) {
            Test.startTest();
            TrialFactory.getTrial(testData.ctp.Id, CommunityService.USER_MODE_PI);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.participantUser) {
            Test.startTest();
            TrialFactory.getTrial(testData.ctp.Id, CommunityService.USER_MODE_PARTICIPANT);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest2() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.participantUser) {
            Test.startTest();
            TrialFactory.getTrial(testData.ctp.Id, CommunityService.USER_MODE_PARTICIPANT, false);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest3() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.participantUser) {
            Test.startTest();
            String delegateID;
            TrialFactory.getTrial(
                testData.ctp.Id,
                CommunityService.USER_MODE_PARTICIPANT,
                delegateID
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest4() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.participantUser) {
            Test.startTest();
            TrialFactory.getTrial(testData.ctp.Id, CommunityService.USER_MODE_PARTICIPANT, true);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest5() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.participantUser) {
            Test.startTest();
            String delId;
            TrialFactory.getTrial(
                CommunityService.USER_MODE_PARTICIPANT,
                testData.ctp.Id,
                delId,
                false
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest6() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.participantUser) {
            Test.startTest();
            String delId;
            TrialFactory.getTrial(
                CommunityService.USER_MODE_PARTICIPANT,
                testData.ctp.Id,
                delId,
                true
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest7() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.piUser) {
            Test.startTest();
            String delId;
            TrialFactory.getTrial(CommunityService.USER_MODE_PI, testData.ctp.Id, delId, false);
        }
        Test.stopTest();
    }

    @IsTest
    static void basePartTest8() {
        TestData testData = new TestData();

        Account hcpAccount = [SELECT Id FROM Account WHERE Name = 'HCP Account'];

        List<Clinical_Trial_Profile__c> ctpList = [
            SELECT Id, CommunityTemplate__c
            FROM Clinical_Trial_Profile__c
            LIMIT 1
        ];
        ctpList[0].CommunityTemplate__c = 'Janssen';
        update ctpList;
        System.runAs(testData.piUser) {
            Test.startTest();
            String delId;
            TrialFactory.getTrial(CommunityService.USER_MODE_HCP, testData.ctp.Id, delId, false);
        }
        Test.stopTest();
    }
}
