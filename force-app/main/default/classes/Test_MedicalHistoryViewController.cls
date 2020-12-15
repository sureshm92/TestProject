@isTest
public class Test_MedicalHistoryViewController {
    @TestSetup
    static void init() {
        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }
    
    @IsTest
    public static void runTest() {
        TestData testDataInst = new TestData();
		Test.startTest();
        System.runAs(testDataInst.piDelUser)
        {
            MedicalHistoryViewController.getMedicalHistory(testDataInst.pe.Id);
        }    
		Test.stopTest();
	}
}