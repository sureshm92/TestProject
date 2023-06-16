@IsTest(IsParallel=false)
private class Test_StudyDetailItem {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        TestData.createTCAcceptance();
        Test.stopTest();
    }

    @isTest
    static void test1() {
        TestData testData = new TestData();
        Participant__c part = [
            SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Suffix__c
            FROM Participant__c
            LIMIT 1
        ];
        Study_Site__c ss = [
            SELECT Id, Principal_Investigator__c
            FROM Study_Site__c
            WHERE Principal_Investigator__c = :testData.piUser.ContactId
            LIMIT 1
        ];
        Contact piother = new Contact();
        piother.LastName = 'dummy';
        piother.Email = 'a@a.com';
        insert piother;
        ss.Principal_Investigator__c = piother.Id;
        System.runAs(testData.piUser) {
            StudyDetailItem.studySiteWithActions sa = new StudyDetailItem.studySiteWithActions(
                ss,
                new List<StudyActions.Action>(),
                new List<Account>(),
                part
            );
        }
    }

    @isTest
    static void test2() {
        TestData testData = new TestData();
        Participant__c part = [
            SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Suffix__c
            FROM Participant__c
            LIMIT 1
        ];
        Study_Site__c ss = [
            SELECT
                Id,
                Principal_Investigator__c,
                Principal_Investigator__r.Salutation,
                Principal_Investigator__r.FirstName,
                Principal_Investigator__r.LastName,
                Principal_Investigator__r.Suffix
            FROM Study_Site__c
            WHERE Principal_Investigator__c = :testData.piUser.ContactId
            LIMIT 1
        ];
        Contact piother = new Contact();
        piother.LastName = 'dummy';
        piother.Email = 'a@a.com';
        insert piother;
        ss.Principal_Investigator__c = piother.Id;
        System.runAs(testData.piUser) {
            StudyDetailItem.studySiteWithActions sa = new StudyDetailItem.studySiteWithActions(
                ss,
                new List<StudyActions.Action>(),
                new List<Account>(),
                null
            );
        }
    }

    @isTest
    static void test3() {
        TestData testData = new TestData();
        Participant__c part = [
            SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Suffix__c
            FROM Participant__c
            LIMIT 1
        ];
        Study_Site__c ss = [
            SELECT
                Id,
                Principal_Investigator__c,
                Principal_Investigator__r.Salutation,
                Principal_Investigator__r.FirstName,
                Principal_Investigator__r.LastName,
                Principal_Investigator__r.Suffix
            FROM Study_Site__c
            WHERE Principal_Investigator__c = :testData.piUser.ContactId
            LIMIT 1
        ];
        Contact piother = new Contact();
        piother.LastName = 'dummy';
        piother.Email = 'a@a.com';
        insert piother;
        ss.Principal_Investigator__c = piother.Id;
        ss.Principal_Investigator__r.Salutation = 'aa';
        System.runAs(testData.piUser) {
            StudyDetailItem.studySiteWithActions sa = new StudyDetailItem.studySiteWithActions(
                ss,
                new List<StudyActions.Action>(),
                new List<Account>(),
                null
            );
        }
    }

    @isTest
    static void test4() {
        TestData testData = new TestData();
        Participant__c part = [
            SELECT Id, Salutation__c, First_Name__c, Last_Name__c, Suffix__c
            FROM Participant__c
            LIMIT 1
        ];
        Study_Site__c ss = [
            SELECT
                Id,
                Principal_Investigator__c,
                Principal_Investigator__r.Salutation,
                Principal_Investigator__r.FirstName,
                Principal_Investigator__r.LastName,
                Principal_Investigator__r.Suffix
            FROM Study_Site__c
            WHERE Principal_Investigator__c = :testData.piUser.ContactId
            LIMIT 1
        ];
        Contact piother = new Contact();
        piother.LastName = 'dummy';
        piother.Email = 'a@a.com';
        insert piother;
        ss.Principal_Investigator__c = piother.Id;
        ss.Principal_Investigator__r.Salutation = 'aa';
        StudyDetailItem.studySiteWithActions bb = new StudyDetailItem.studySiteWithActions();
        System.runAs(testData.piUser) {
            StudyDetailItem.studySiteWithActions sa = new StudyDetailItem.studySiteWithActions(
                ss,
                new List<StudyActions.Action>(),
                new List<Account>(),
                part
            );
        }
    }

    @IsTest
    static void testStudyDetailItem() {
        StudyDetailItem sdi1 = new StudyDetailItem();
        sdi1.maxHCPCreatedDate = Datetime.now();
        sdi1.sites = new List<StudySiteService.StudySiteDistanceWrapper>();
        sdi1.studyActions = new List<StudyActions.Action>();
        sdi1.trial = new Clinical_Trial_Profile__c();
        sdi1.trial.Study_Code_Name__c = 'XYZ';
        StudySiteService.StudySiteDistanceWrapper site1 = new StudySiteService.StudySiteDistanceWrapper();
        site1.distance = 12;
        sdi1.sites.add(site1);

        StudyDetailItem sdi2 = new StudyDetailItem();
        sdi2.maxHCPCreatedDate = Datetime.now().addDays(-100);
        sdi2.sites = new List<StudySiteService.StudySiteDistanceWrapper>();
        StudySiteService.StudySiteDistanceWrapper site2 = new StudySiteService.StudySiteDistanceWrapper();
        site2.distance = 100;
        sdi2.trial = new Clinical_Trial_Profile__c();
        sdi2.trial.Study_Code_Name__c = 'AB';
        sdi2.sites.add(site2);

        StudyDetailItem sdi3 = new StudyDetailItem();
        sdi3.maxHCPCreatedDate = Datetime.now().addDays(-50);
        sdi3.sites = new List<StudySiteService.StudySiteDistanceWrapper>();

        StudyDetailItem sdi4 = new StudyDetailItem();
        sdi4.sites = new List<StudySiteService.StudySiteDistanceWrapper>();
        StudySiteService.StudySiteDistanceWrapper site3 = new StudySiteService.StudySiteDistanceWrapper();
        site3.distance = null;
        sdi4.sites.add(site3);

        Test.startTest();
        Integer res;
        StudyDetailItem.sortType = 'Distance ASC';
        res = sdi1.compareTo(sdi2);
        res = sdi2.compareTo(sdi3);
        res = sdi3.compareTo(sdi1);
        res = sdi1.compareTo(sdi1);
        res = sdi1.compareTo(sdi4);
        res = sdi4.compareTo(sdi1);
        res = sdi3.compareTo(sdi3);

        StudyDetailItem.sortType = 'CreatedDate DESC';
        res = sdi1.compareTo(sdi2);
        res = sdi2.compareTo(sdi1);
        res = sdi1.compareTo(sdi1);

        StudyDetailItem.sortType = 'Name';
        Integer a = sdi1.compareTo(sdi2);
        Integer b = sdi2.compareTo(sdi1);
        Integer c = sdi1.compareTo(sdi1);

        Test.stopTest();
    }
}
