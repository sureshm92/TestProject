@IsTest
public class Test_Batch_CSVImportBatchJob {
     @IsTest
    static void testImportSiteStaff(){
         Test.startTest();
       
                 Account SiteAccount = new Account(
                Name = 'Study Site Account',
                BillingCountry = 'United States'
            );
            insert SiteAccount;

            Contact con = new Contact(
                FirstName = 'PITD',
                LastName = 'PITD',
                AccountId = SiteAccount.Id,
                UserCommunityIsDelegate__c = true
            );
            insert con;
         Batch_CSVImportBatchJob.importData impt = new Batch_CSVImportBatchJob.importData();
        impt.allContactIdS = con.Id;
         Document document;
    document = new Document();
    document.Body = Blob.valueOf(impt.allContactIdS);
    document.ContentType = 'application/pdf';
    document.DeveloperName = 'DemoCSV4';
    document.IsPublic = true;
    document.Name = 'DemoCSV4';
    document.FolderId = [select id from folder where name = 'CreatingContact'].id;
    insert document;

            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                CommunityTemplate__c = 'GSK',
                Suppress_Participant_Emails__c = false
            );
            insert clinical;

            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                Principal_Investigator__c = con.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = SiteAccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
         Site_Staff__c siteStaff = new Site_Staff__c(
                Delegate_Level__c = 'Level 1',
                Study_Site__c = studySite.Id,
                Site_Contact__c = con.Id,
                is_Invited__c = true
            );
            insert siteStaff;
            
       
    
      Database.executeBatch(new Batch_CSVImportBatchJob(), 20);
        Test.stopTest();
    }

}