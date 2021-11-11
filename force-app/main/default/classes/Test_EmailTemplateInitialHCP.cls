@isTest
public class Test_EmailTemplateInitialHCP {
	@TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData(); 
        Test.stopTest();
    }
    
    @isTest
    public static void runTest() {
        TestData tstData = new TestData();
        List<Participant_Enrollment__c> peList = [SELECT Id,HCP__c, PI_Contact__c, Study_Site__c 
                                                  FROM Participant_Enrollment__c];
                                                 	//WHERE HCP_Enrollment__c =:tstData.hcpEnrollment.Id];
        
        System.debug('peList:'+peList);
        Healthcare_Provider__c provider = new Healthcare_Provider__c();
        provider.HCP_Enrollment__c = tstData.hcpEnrollment.Id;
        provider.Participant_Enrollment__c = peList[0].Id;
        insert provider;
        
        Test.startTest();
        EmailTemplateInitialHCP email=new EmailTemplateInitialHCP( tstData.hcpEnrollment.HCP_Contact__c,'HTML');
        Test.stopTest();
    }
    
     @isTest
    public static void runTestHCPDel() {
        TestData tstData = new TestData();
		Test.startTest();
        EmailTemplateInitialHCPDel email=new EmailTemplateInitialHCPDel( tstData.hcpEnrollment.HCP_Contact__c,'HTML');
        Test.stopTest();      
    }
}