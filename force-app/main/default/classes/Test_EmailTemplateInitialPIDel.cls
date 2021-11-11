@isTest
public class Test_EmailTemplateInitialPIDel {
	@TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData(); 
        Test.stopTest();
    }
    
    @isTest
    public static void runTest() {
        TestData tstData = new TestData();
        Test.startTest();
        EmailTemplateInitialPIDel email=new EmailTemplateInitialPIDel( tstData.piDelegateContact.Id,'HTML','Default');
        Test.stopTest();
    }
}