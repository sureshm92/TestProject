@isTest(isParallel = false)
public class nonReferedBulkUpload_Test {
  @TestSetup
    static void setup() {
        TestData.loadTestData();
    }
    @isTest
    public static void TestM1(){
         TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        test.startTest();
        string fId = nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , '.xlsx', ''); 
        nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'xlsx', fId);
        string csvData = 'x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x\nx,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x\n,,,,,cherry@yop.com,2010,Yes,No,,,76767,,,,x,,,,,1998,No,err\n1234,,,,,,,,,,,,,,,,,,,,,,err\n1224,,,,,,1982,Yes,,,,,,,,x,,,,,,,err\n1234,,,,,,,,,,,,,,,,,,,,,,err\nSomePatientId1,,,,,,,,,,,,,,,,,,,,,,err\n1562,,,,,,2010,No,,,,456791001,Work,,,m,c,m@c.com,78965413,Work,1962,Yes,err\n';
        string csvData22 = 'x,x,x,x,x,x\nx,x,x,x,x,x,x,x\nx,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x';
        string csvData21 = 'x,x,x,x,x,x\nx,x,x,x,x,x,x,x\nx,x,x,x,x,x,No,No,x,x,x,x,x,x,x,x,x,x,x,x,No,No';
      ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test.csv',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
              
        );
        insert contentVersionInsert;
        string studyID = [select Study_Site__c from HCP_Enrollment__c where HCP_Contact__c =: u.contactid limit 1].Study_Site__c;
        nonReferedBulkUpload.processvalidateFile(contentVersionInsert.id, studyID, 'New York', 'United States', csvData, u.ContactId);
        nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData, u.ContactId);
        nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData22, u.ContactId);
        nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData21, u.ContactId);
         nonReferedBulkUpload.fetchFiles(u.ContactId);
        System.runAs(testData.piUser) {    
            nonReferedBulkUpload.fetchFiles(null);
            nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData22, u.ContactId);
            nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', '', null);
        }
        try{
            nonReferedBulkUpload.fetchFiles(null);
            nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', '', null);
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        nonReferedBulkUpload.deleteFile(fId);
        nonReferedBulkUpload n = new nonReferedBulkUpload();
        test.stopTest();
    }
    @isTest
    public static void TestM3(){
         TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        test.startTest();
         string fId = nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'xlsx', '');
        string csvData22 = 'x,x,x,x,x,x\nx,x,x,x,x,x,x,x\nx,x,x,x,x,x,1998,1998,x,India,India,x,x,x,x,x,x,x,x,x';
        string csvData21 = 'x,x,x,x,x,x\nx,x,x,x,x,x,x,x\nx,x,x,x,x,x,No,No,x,x,x,x,x,x,x,x,x,x,x,x,No,No';

        string studyID = [select Study_Site__c from HCP_Enrollment__c where HCP_Contact__c =: u.contactid limit 1].Study_Site__c;

        nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData22, u.ContactId);
        nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData21, u.ContactId);
        System.runAs(testData.piUser) {    
            nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', '', null);
        }
        try{
            nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', '', null);
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        test.stopTest();
    }
     @isTest
    public static void TestM4(){
         TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        test.startTest();
         string fId = nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'xlsx', '');
     string csvData22 = 'x,x,x,x,x,x\nx,x,x,x,x,x,x,x\nx,x,x,x,x,x,1998,1998,x,x,x,x,x,x,x,x,x,x,Yes,Yes,Yes,Yes,Yes';
    
        string studyID = [select Study_Site__c from HCP_Enrollment__c where HCP_Contact__c =: u.contactid limit 1].Study_Site__c;

        nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData22, u.ContactId);
        System.runAs(testData.piUser) {    
            nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', '', null);
        }
        try{
            nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', '', null);
        }
        catch(Exception ex) {System.assertEquals(ex.getMessage(),'Script-thrown exception' );}
        test.stopTest();
    }
    @isTest
    public static void TestM5(){
         TestData testData = new TestData();
        user u = [select id,contactid from user where LastName = 'HCPTD' ];
        test.startTest();
        
        string fId = nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'xlsx', '');
        string csvData22 = 'x,x,x,x,x,x\nx,x,x,x,x,x,x,x\nx,x,x,x,x,x,1998,1998,x,India,India,x,x,x,x,x,x,x,x,x';
         ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'test_errors.csv',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
              
        );
        insert contentVersionInsert;
        string studyID = [select Study_Site__c from HCP_Enrollment__c where HCP_Contact__c =: u.contactid limit 1].Study_Site__c;

        nonReferedBulkUpload.processvalidateFile(contentVersionInsert.id, studyID, 'New York', 'United States', csvData22, u.ContactId);
        test.stopTest();
    }
    @isTest
    public static void TestM2(){
        user u = [select id,contactid from user where LastName = 'HCPTD'];
        system.runAs(u){
            test.startTest();
          FileContainer.getHCPInitData(u.ContactId,'HCP');
            FileContainer.getShowInstructValue(true);
            test.stopTest();
        }
    }
}