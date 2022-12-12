@IsTest
public class Test_Batch_CSVImportBatchJob {
    public static set<Id>passingStaffcontactId;
    @IsTest
    static void testImportSiteStaff(){
        UserRole userRole_1 = [SELECT Id FROM UserRole WHERE Name = 'View All' LIMIT 1];
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        User admin = [
            SELECT Id, Username, UserRoleId
            FROM User
            WHERE
            Profile.Name = 'System Administrator'
            AND UserRoleId = :userRole_1.Id
            AND IsActive = TRUE
            LIMIT 1
        ];
        User user_1;
        Test.startTest();
         List<Batch_CSVImportBatchJob.importData>importLST = new List<Batch_CSVImportBatchJob.importData>();
        System.runAs(admin) {
            Account usraccount = new Account(Name = 'Community');
            insert usraccount;
            Contact usrcontact = new Contact(AccountId = usraccount.Id, LastName = 'xgeek',email = 'yourusername@gmail.com' ,UserCommunityIsDelegate__c = true);
            insert usrcontact;
            //passingStaffcontactId = new set<Id>();
           // passingStaffcontactId.add(usrcontact.Id);   
            Document document;
            document = new Document();
            document.Body = Blob.valueOf(usrcontact.Id);
            document.ContentType = 'application/pdf';
            document.DeveloperName = 'DemoCSV4';
            document.IsPublic = true;
            document.Name = 'DemoCSV4';
            document.FolderId = [select id,developerName from folder where developerName = 'Mass_email_images'].id;
            insert document;
           
            Batch_CSVImportBatchJob.importData impt = new Batch_CSVImportBatchJob.importData();
            impt.allContactIdS = usrcontact.Id;
            importLST.add(impt);
            
            Clinical_Trial_Profile__c clinical = new Clinical_Trial_Profile__c(
                Protocol_ID__c = 'tt123456790',
                Override_Recruitment_Status__c = 'Actively Enrolling',
                NCT_Number__c = 'NCT00000002',
                Link_to_Pre_screening__c = 'some link',
                Study_Title__c = 'Some Title',
                Study_Code_Name__c = 'Some Code Name',
                Suppress_Participant_Emails__c = false
            );
            insert clinical;
            Study_Site__c studySite = new Study_Site__c(
                Name = 'Test',
                //Principal_Investigator__c = usrcontact.Id,
                Clinical_Trial_Profile__c = clinical.Id,
                Site__c = usraccount.Id,
                Study_Site_Type__c = 'Traditional',
                Suppress_Participant_Emails__c = false
            );
            insert studySite;
            Site_Staff__c siteStaff = new Site_Staff__c(
                Delegate_Level__c = 'Level 1',
                Study_Site__c = studySite.Id,
                Site_Contact__c = impt.allContactIdS,
                is_Invited__c =  true
            );
            insert siteStaff;        
            Datetime timeStamp = Datetime.now();   
            List<Action__c> pendingActions = [
                SELECT Id, Body__c, Status__c, CreatedDate
                FROM Action__c
                WHERE Type__c = 'Action_AssignContactPermissions' AND CreatedDate >= :timeStamp
            ];
        }
        Batch_CSVImportBatchJob.import(importLST);
        Database.executeBatch(new Batch_CSVImportBatchJob(), 20);
        Test.stopTest(); 
    }
    
}