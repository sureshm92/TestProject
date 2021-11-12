@isTest
public class Test_EmailTemplateInitialCC {
	@TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData(); 
        Test.stopTest();
    }
    
    @IsTest
    public static void runTest() {
        TestData tstData = new TestData();
        Test.startTest();
        //System.runAs(tstData.ccUser) {
        	EmailTemplateInitialCC email=new EmailTemplateInitialCC( tstData.piDelegateContact.Id,'HTML');
        //}
        
    }
}