/**
 * Test class for deleting PI bulk import error files which are more than 6 months old.
*/

@isTest
public with sharing class Batch_ContentVersionDel_SchedulerTest {
    public static String CRON_EXP = '0 0 0 10 2 ? 2022';
    @TestSetup
    static void setup() {
        List<Bulk_Import_History__c> bulkImportList = new List<Bulk_Import_History__c>();
        Bulk_Import_History__c bulkHistory = new Bulk_Import_History__c(File_Name__c='Test',Import_Status__c='In Progress', Download_URL__c='/sfc/servlet.shepherd/document/download/0698E000002PgGRQA0');
        bulkImportList.add(bulkHistory);

        Bulk_Import_History__c bulkHistory1 = new Bulk_Import_History__c(File_Name__c='Test1',Import_Status__c='In Progress', Download_URL__c='/sfc/servlet.shepherd/document/download/0698E000002PgGRQA0');
        bulkImportList.add(bulkHistory1);

        Bulk_Import_History__c bulkHistory2 = new Bulk_Import_History__c(File_Name__c='Test2',Import_Status__c='In Progress', Download_URL__c='/sfc/servlet.shepherd/document/download/0698E000002PgGRQA0');
        bulkImportList.add(bulkHistory2);

        Bulk_Import_History__c bulkHistory3 = new Bulk_Import_History__c(File_Name__c='Test3',Import_Status__c='In Progress', Download_URL__c='/sfc/servlet.shepherd/document/download/0698E000002PgGRQA0');
        bulkImportList.add(bulkHistory3);
        
        insert bulkImportList;

        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion);   
        
        ContentVersion contentVersion2 = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'testFile.mp3',
            VersionData = Blob.valueOf('Test Content sadas'),
            IsMajorVersion = true
        );
        contentVersionList.add(contentVersion2);
        insert contentVersionList;
            
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        for(Integer i = 0; i < 2; i++){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = bulkImportList[i].Id;
            cdl.ContentDocumentId =documents[0].Id;
            cdl.shareType = 'I';

            contentDocList.add(cdl);
        }
        Insert contentDocList;         
    }

    public static testMethod void deletionSuccess(){
        Batch_ContentVersionDeletion_Scheduler csSch = new Batch_ContentVersionDeletion_Scheduler();
        System.schedule('Sample_heading',CRON_EXP,csSch);
        Test.startTest();
            Batch_ContentVersionDeletion myBatcObj = new Batch_ContentVersionDeletion();
            Database.executeBatch(myBatcObj,200);
        Test.StopTest();
		List<ContentDocument> contentList = [SELECT Id FROM ContentDocument];
        System.AssertEquals(1, contentList.size());
    }
}