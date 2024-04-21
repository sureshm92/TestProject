@isTest
public class PpPastStudiesFilesControllerTest {
    @TestSetup
    static void init(){
        TestData.loadTestData(); 
    }
    @isTest
    static void getStudyListTest() {
        TestData testData = new TestData();
        test.startTest();
         Contact c = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert c;
          
        
        Participant_Enrollment__c parList = new Participant_Enrollment__c();
         parList.Participant_Status__c = 'Drop Out';
         parList.Participant_Contact__c = testData.piContact.id;
         parList.Clinical_Trial_Profile__c = testData.ctp.id;
         parList.Study_Site__c = testData.ss.Id;
        insert parList;
        
        
       
        PpPastStudiesFilesController.getStudyList(testData.piContact.id,true);
        Test.stopTest();
    }
    @isTest
    static void fetchUploadedFilesTest() {
        TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'PITD' ];
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        
          List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = testData.pe.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);

        insert contentDocList;
        
        List<string> cv= new List<string>();
        Set<id> cd= new Set<id>();
        cd.add(documents[0].id);
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test.pdf',
            PathOnClient = 'Test.pdf',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true,
            ContentDocumentId=documents[0].id,
            FileStatus__c='Uploaded'
              
        );
        insert contentVersionInsert;
        test.startTest();
      
        Participant_Enrollment__c parList = new Participant_Enrollment__c();
         parList.Participant_Status__c = 'Drop Out';
         parList.Participant_Contact__c = testData.piContact.id;
         parList.Clinical_Trial_Profile__c = testData.ctp.id;
         parList.Study_Site__c = testData.ss.Id;
        insert parList;
         User delegate = testData.createPatientDelegate();
        insert delegate;
         Id delegateContactId = [SELECT ContactId FROM User WHERE Id = :delegate.Id].ContactId;
        Patient_Delegate__c patientDelegate = [
            SELECT Id, Participant__c, Contact__c
            FROM Patient_Delegate__c
            WHERE Contact__c = :delegateContactId
        ];
        patientDelegate.Status__c = 'Active';
        update patientDelegate;
         Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = parList.id;
        pde.Patient_Delegate__c  = patientDelegate.id;
        pde.Status__c = 'Active';
        pde.Primary_Delegate__c=true;
        insert pde;
        cv.add(contentVersionInsert.id);
          System.runAs(testData.participantUser) {
            PpPastStudiesFilesController.fetchUploadedFiles(testData.piContact.id,1,testData.ctp.id , 'CreatedDate', 'ASC',true,true);
            PpPastStudiesFilesController.fetchUploadedFiles(testData.piContact.id,1,testData.ctp.id , 'CreatedDate', 'ASC',false,true);

          } 
        PpPastStudiesFilesController.deleteFile(contentVersionInsert.id);
    	 

        Test.stopTest();
    }

}