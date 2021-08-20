@isTest
public class RPRecordReviewLogController_TEST {
	@TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    @isTest
    public static void TestM1(){
        TestData testData = new TestData();
        RPRecordReviewLogController.getPEDetails();  
        RPRecordReviewLogController.getRecordsDetails();  
        RPRecordReviewLogController.getContactList();  
        RPRecordReviewLogController.getPECountDetails();  
        RPRecordReviewLogController.dateFormatChange(system.today());
        RPRecordReviewLogController.peInitData pei =  new RPRecordReviewLogController.peInitData(null,null,null);
    }
}