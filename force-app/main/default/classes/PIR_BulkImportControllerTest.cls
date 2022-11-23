@isTest
public class PIR_BulkImportControllerTest {
    @TestSetup
    static void init(){
        TestData.loadTestData(); 
    }
    @isTest
    static void testgetStudyAccessLevel() {
        TestData testData = new TestData();
        Test.startTest();

        Account studySiteAccount = [SELECT Id FROM Account WHERE Name = 'Study Site Account' LIMIT 1];

        System.runAs(testData.piUser) {

            PIR_BulkImportController.getStudyStudySiteDetails();
        }

        Study_Site__c studySite = new Study_Site__c(
            Principal_Investigator__c = testData.piContact.Id,
            Clinical_Trial_Profile__c = testData.ctp.Id,
            Override_PI_Referral_Status__c = StudySiteService.PI_S_INVITATION_SENT,
            Site__c = studySiteAccount.Id,
            Study_Site_Type__c = 'Traditional',
            Suppress_Participant_Emails__c = false,
            Study_Site_Number__c = 'SS2',
            Billable_Code_CRM_Number__c = 'Test_Billable_Code',
            Enable_for_Call_Center_Support__c = true
        );
        insert studySite;

        studySite.Override_PI_Referral_Status__c = StudySiteService.PI_S_ACCEPTED;
        update studySite;

        Site_Staff__c siteStaff = new Site_Staff__c(
            Site_Contact__c = testData.piContact.Id,
            Delegate_Level__c = DelegateService.DELEGATE_LEVEL_1,
            Study_Site__c = testData.ss.Id,
            is_Invited__c = true
        );
        insert siteStaff;

        System.runAs(testData.piUser) {

            PIR_BulkImportController.getStudyStudySiteDetails();
        }
        Test.stopTest();
    }
    @isTest
    static void testGetStudyAccess() {
        TestData testData = new TestData();
        Set<Id> ctpIds = new Set<Id>();
        List<Clinical_Trial_Profile__c> ctpList = [SELECT Id FROM Clinical_Trial_Profile__c];
        for(Clinical_Trial_Profile__c ctp: ctpList) {
            ctpIds.add(ctp.Id);
        }
        
        Test.startTest();
        System.runAs(testData.piUser){
            PIR_BulkImportController.getStudyAccess(ctpIds);
        }

        Terms_And_Conditions__c studyTC = [SELECT Id FROM Terms_And_Conditions__c LIMIT 1];

        Terms_And_Conditions_Acceptance__c tc_acceptance = new Terms_And_Conditions_Acceptance__c(
            User__c = testData.piUser.Id,
            Terms_And_Conditions__c = studyTC.Id
        );
        insert tc_acceptance;

        System.runAs(testData.piUser){
            PIR_BulkImportController.getStudyAccess(ctpIds);
        }
        Test.stopTest();
    }
    
    @isTest
    static void getShowInstructValue() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            PIR_BulkImportController.getShowInstructValue(true);
        }
        Test.stopTest();
    }
     @isTest
    static void getInstruction() {
        TestData testData = new TestData();
        Test.startTest();
        System.runAs(testData.piUser) {
            PIR_BulkImportController.getInstruction();
        }
        Test.stopTest();
    }
     @isTest
    static void getBulkImportHistoryCompleted() {
        TestData testData = new TestData();
        Test.startTest();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        ssList = [SELECT Id FROM Study_Site__c];
        List<String> getstudysite=new List<String>();
        List<String> getstudysiteEmpty=new List<String>();
        for(Study_Site__c ss:ssList){
            getstudysite.add(ss.id);
        }
        System.runAs(testData.piUser) {
            PIR_BulkImportController.getBulkImportHistoryCompleted(getstudysiteEmpty,1);
            PIR_BulkImportController.getBulkImportHistoryCompleted(getstudysite,1);
            PIR_BulkImportController.getBulkImportHistoryCompleted(new List<String>{testData.ctp.Id},1);
        }
        Test.stopTest();
    }
    @isTest
    static void getBulkImportHistoryInProgress() {
        TestData testData = new TestData();
        Test.startTest();
        List<Study_Site__c> ssList = new List<Study_Site__c>();
        ssList = [SELECT Id FROM Study_Site__c];
        List<String> getstudysite=new List<String>();
        List<String> getstudysiteEmpty=new List<String>();
        for(Study_Site__c ss:ssList){
            getstudysite.add(ss.id);
        }
        System.runAs(testData.piUser) {
            PIR_BulkImportController.getBulkImportHistoryInProgress(getstudysiteEmpty);
            PIR_BulkImportController.getBulkImportHistoryInProgress(getstudysite);
        }

        insert new Bulk_Import_History__c(
            File_Name__c = 'Test File001', Study_Site__c = testData.ss.Id, Import_Status__c = 'In Progress',
            Uploaded_By__c = testdata.piContact.Id
        );
        System.runAs(testData.piUser) {
            PIR_BulkImportController.getBulkImportHistoryInProgress(getstudysiteEmpty);
            PIR_BulkImportController.getBulkImportHistoryInProgress(getstudysite);
            PIR_BulkImportController.getBulkImportHistoryInProgress(new List<Id>{testData.ctp.Id});
        }

        
        Test.stopTest();
    }
}