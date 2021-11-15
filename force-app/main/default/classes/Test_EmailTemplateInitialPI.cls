@isTest
public class Test_EmailTemplateInitialPI {
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
        EmailTemplateInitialPI email=new EmailTemplateInitialPI( tstData.piContact.Id,'HTML','Default');
        Test.stopTest();
    }
}