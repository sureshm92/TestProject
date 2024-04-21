@isTest
public class ppFileUploadControllerTest {
    @TestSetup
    static void init(){
        TestData.loadTestData(); 
    }
    @isTest
    static void saveTheChunkFileTest() {
        TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
       
        test.startTest();
        string fId = ppFileUploadController.saveTheChunkFile(u.ContactId, 'Test.pdf', EncodingUtil.base64Encode(blob.valueOf('File test data')) , '.pdf', '','',true,false,'99',true); 
        
        ppFileUploadController.saveTheChunkFile(u.ContactId, 'Testttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuggggggggggggggggggggggggggggggggggggg.pdf', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'pdf', '','',false,false,'99',false);
        ppFileUploadController.saveTheChunkFile(u.ContactId, 'Test.pdf', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'pdf', '','',true,false,'99',false);
        ppFileUploadController.fetchUploadedFiles(testData.pe.Id, 1, true , 'CreatedDate', 'ASC',false,true);
        
        ppFileUploadController.fetchFiles(u.ContactId);
        string fIdn = nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , '.xlsx', ''); 
         ContentVersion contentVersionInsert = new ContentVersion(
             Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
              
        );
        Insert contentVersionInsert;
		Id newId = Id.valueOf(fIdn);
        ContentDistribution cdist = new ContentDistribution(
                                        Name = contentVersionInsert.Title,
                                        ContentVersionId = newId
                                        );
        insert cdist;
        ppFileUploadController.saveTheChunkFile(u.ContactId, 'Test.pdf', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'pdf', fIdn,'',false,false,'99',false);
        ppFileUploadController.saveTheChunkFile(u.ContactId, 'Test.pdf', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'pdf', fIdn,'',false,true,'99',false);
        Test.stopTest();
    }
    @isTest
    static void checkifPrimaryTest() {
        TestData testData = new TestData();
        test.startTest();
         Contact delegate = new Contact(
            FirstName = 'Patient',
            LastName = 'Delegate',
            Email = 'jsmith@somemail.com',
          
            userCommunityMode__c = CommunityService.USER_MODE_PARTICIPANT,
            userCommunytyType__c = CommunityService.USER_MODE_PARTICIPANT,
            UserCommunityIsDelegate__c = true
        );
        insert delegate;
        
        Participant__c p = new Participant__c(
            First_Name__c = 'Patient',
            Last_Name__c = 'Delegate',
            Contact__c = delegate.Id
        );
        insert p;

        Patient_Delegate__c patientDelegate = new Patient_Delegate__c(
            Contact__c = delegate.Id,
            Contact__r = delegate,
            Participant__c = p.Id,
            Participant__r = p
        );
        insert patientDelegate;
 
        
        Patient_Delegate_Enrollment__c pde = new Patient_Delegate_Enrollment__c();
        pde.Participant_Enrollment__c = testData.pe.Id;
        pde.Patient_Delegate__c = patientDelegate.Id;
        pde.Primary_Delegate__c = true;
        pde.Status__c = 'Active';
        Insert pde;
        
        ppFileUploadController.checkifPrimary(testData.pe.Id,delegate.Id);
        Test.stopTest();
    }
     @isTest
    static void fetchUploadedFilesTest() {
        TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        
        List<Participant_Enrollment__c> objpart = [SELECT Id,Participant__r.BMI__c,Comorbidities__c,HighRisk_Indicator__c,High_Priority__c,Referral_Source__c,Participant__c
        ,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c,Study_Site__c,Unique_HumanId__c,MRR_Survey_Results_URL__c FROM Participant_Enrollment__c ];
        
         List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
          List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objpart[0].Participant__c;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);

        insert contentDocList;
        
        List<string> cv= new List<string>();
        Set<id> cd= new Set<id>();
        cd.add(documents[0].id);
        ContentVersion contentVersionInsert = new ContentVersion(
             Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
              
        );
        Insert contentVersionInsert;
      
        cv.add(contentVersionInsert.id);
       Conversation__c conversation = new Conversation__c(
            Participant_Enrollment__c = testData.pe.Id
        );
        insert conversation;
        insert ConversationService.createConversationSharesForUser(
            new List<Id>{ conversation.Id },
            testData.participantUser.Id
        );
        insert new Message__c(
            Conversation__c = conversation.Id,
            Message_Content__c = 'Why???',
            Sender_Name__c = 'Morgan Stark'
        ); 
    
        test.startTest();
       
                              
        try{
             ppFileUploadController.fetchUploadedFiles(testData.pe.Id, 1, true , 'CreatedDate', 'ASC',true,true);
        System.runAs(testData.participantUser) {
        ppFileUploadController.fetchMessageFiles(testData.pe.Id, 1, 'CreatedDate', 'ASC',true,true);
        }
        ppFileUploadController.isUplaodAvailable(testData.pe.Id);
        ppFileUploadController.deleteFilewithlist(cv,testData.pe.Id);
        ppFileUploadController.DeleteAlldraftFiles(testData.pe.Id);
        ppFileUploadController.deleteFile(contentVersionInsert.id);
       
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        string fId = ppFileUploadController.saveTheChunkFile(u.ContactId, 'Testttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuggggggggggggggggggggggggggggggggggggg.pdf', EncodingUtil.base64Encode(blob.valueOf('File test data')) , '.pdf', '','',true,false,'99',true); 
        

        Test.stopTest();
    }
    @isTest
    static void fetchUploadedFilesTest12() {
        TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        
        List<Participant_Enrollment__c> objpart = [SELECT Id,Participant__r.BMI__c,Comorbidities__c,HighRisk_Indicator__c,High_Priority__c,Referral_Source__c,Participant__c
        ,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c,Study_Site__c,Unique_HumanId__c,MRR_Survey_Results_URL__c FROM Participant_Enrollment__c ];
        
         List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
          List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objpart[0].Participant__c;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);

        insert contentDocList;
        
        List<string> cv= new List<string>();
        Set<id> cd= new Set<id>();
        cd.add(documents[0].id);
        ContentVersion contentVersionInsert = new ContentVersion(
             Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
              
        );
        Insert contentVersionInsert;
      
        cv.add(contentVersionInsert.id);
       Conversation__c conversation = new Conversation__c(
            Participant_Enrollment__c = testData.pe.Id
        );
        insert conversation;
        insert ConversationService.createConversationSharesForUser(
            new List<Id>{ conversation.Id },
            testData.participantUser.Id
        );
        insert new Message__c(
            Conversation__c = conversation.Id,
            Message_Content__c = 'Why???',
            Sender_Name__c = 'Morgan Stark'
        );
        test.startTest(); 
        try{
             ppFileUploadController.fetchUploadedFiles(testData.pe.Id, 1, true , 'CreatedDate', 'ASC',false,true);
        System.runAs(testData.participantUser) {
        ppFileUploadController.fetchMessageFiles(testData.pe.Id, 1, 'ContentDocument.CreatedDate', 'ASC',false,true);
        }
        ppFileUploadController.isUplaodAvailable(testData.pe.Id);
        ppFileUploadController.deleteFilewithlist(cv,testData.pe.Id);
        ppFileUploadController.DeleteAlldraftFiles(testData.pe.Id);
        ppFileUploadController.deleteFile(contentVersionInsert.id);
         
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        string fId = ppFileUploadController.saveTheChunkFile(u.ContactId, 'Testttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttttyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuggggggggggggggggggggggggggggggggggggg.pdf', EncodingUtil.base64Encode(blob.valueOf('File test data')) , '.pdf', '','',true,false,'99',true); 
        

        Test.stopTest();
    }
    @isTest
    static void isUplaodAvailableTest() {
        TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        
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
            FileStatus__c='Draft'
              
        );
        Insert contentVersionInsert;
      
        cv.add(contentVersionInsert.id);
        
        test.startTest();
        ppFileUploadController.isUplaodAvailable(testData.pe.Id);

        Test.stopTest();
    }
    @isTest
    static void testUploadFiles() {
        TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        Profile profile_1 = [
            SELECT Id
            FROM Profile
            WHERE Name = 'IQVIA Customer Community Plus Login User'
            LIMIT 1
        ];
        List<Participant_Enrollment__c> objpart = [SELECT Id,Participant__r.BMI__c,Comorbidities__c,HighRisk_Indicator__c,High_Priority__c,Referral_Source__c,Participant__c
        ,Clinical_Trial_Profile__r.Medical_Vendor_is_Available__c,Study_Site__c,Unique_HumanId__c,MRR_Survey_Results_URL__c FROM Participant_Enrollment__c ];
        
         List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
          List<ContentDocumentLink> contentDocList = new List<ContentDocumentLink>();
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = objpart[0].Participant__c;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        cdl.Visibility = 'AllUsers';
        contentDocList.add(cdl);

        insert contentDocList;
        
        List<string> cv= new List<string>();
        Set<id> cd= new Set<id>();
        cd.add(documents[0].id);
        ContentVersion contentVersionInsert = new ContentVersion(
             Title = 'Test File',
            PathOnClient = 'testFile.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
              
        );
        Insert contentVersionInsert;
      
        cv.add(contentVersionInsert.id);
        
       
        List<ppFileUploadcontroller.uploadFileWrapper> testWrapperList = new List<ppFileUploadcontroller.uploadFileWrapper>();
        ppFileUploadcontroller.uploadFileWrapper objWrapper = new ppFileUploadcontroller.uploadFileWrapper();
        
        objWrapper.fileContentVerId = contentVersionInsert.Id;
        objWrapper.isDeleted = false;
        objWrapper.error = false;
        objWrapper.fileName = 'Test File';
        objWrapper.index = 0;
        testWrapperList.add(objWrapper);
       
        
       
        String strFileData = JSON.serialize(testWrapperList);
        
       
        Test.startTest();
        ppFileUploadcontroller.uploadFiles(strFileData,testData.pe.Id);
        ppFileUploadController.fetchMessageFiles(testData.pe.Id, 1, 'CreatedDate', 'ASC',true,true);
        Test.stopTest();
        
        
    }
    }