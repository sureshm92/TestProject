@isTest(isParallel = false)
public class nonReferedBulkUpload_Test {
	@TestSetup
    static void setup() {
        TestData.loadTestData();
    }
    @isTest
    public static void TestM1(){
        user u = [select id,contactid from user where LastName = 'HCPTD'];
        test.startTest();
        string fId = nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'xlsx', '');
        nonReferedBulkUpload.saveTheChunkFile(u.ContactId, 'Test.xlsx', EncodingUtil.base64Encode(blob.valueOf('File test data')) , 'xlsx', fId);
        string csvData = 'x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x\nx,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x\n,,,,,cherry@yop.com,2010,Yes,No,,,76767,,,,x,,,,,1998,No,err\n1234,,,,,,,,,,,,,,,,,,,,,,err\n1224,,,,,,1982,Yes,,,,,,,,x,,,,,,,err\n1234,,,,,,,,,,,,,,,,,,,,,,err\nSomePatientId1,,,,,,,,,,,,,,,,,,,,,,err\n1562,,,,,,2010,No,,,,456791001,Work,,,m,c,m@c.com,78965413,Work,1962,Yes,err\n';
        string studyID = [select Study_Site__c from HCP_Enrollment__c where HCP_Contact__c =: u.contactid limit 1].Study_Site__c;
        nonReferedBulkUpload.processvalidateFile(fId, studyID, 'New York', 'United States', csvData, u.ContactId);
       	nonReferedBulkUpload.fetchFiles(u.ContactId);
        nonReferedBulkUpload.deleteFile(fId);
        nonReferedBulkUpload n = new nonReferedBulkUpload();
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