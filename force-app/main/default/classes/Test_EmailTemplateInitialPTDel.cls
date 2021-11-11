@isTest
public class Test_EmailTemplateInitialPTDel {
	@TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData(); 
        Test.stopTest();
    }
    
    @isTest
    public static void runTest() {
        TestData tstData = new TestData();
        tstData.createPatientDelegate();
        
        Patient_Delegate__c delegate = [SELECT Id, Contact__c,Participant__c FROM Patient_Delegate__c LIMIT 1];
        Test.startTest();
        EmailTemplateInitialPTDel email=new EmailTemplateInitialPTDel( delegate.Contact__c,'HTML', 'Default');
    
   }
}