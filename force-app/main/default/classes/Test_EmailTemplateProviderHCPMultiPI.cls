@isTest
public class Test_EmailTemplateProviderHCPMultiPI {

    @testSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData(); 
        Test.stopTest();
    }
    
    @isTest
    public static void runTest() {
        TestData tstData = new TestData();
        Test.startTest();
        List<HCP_Enrollment__c> hcpenrollList = [SELECT Id,HCP_Contact__r.LastName,HCP_Contact__r.Language__c,HCP_Contact__c,HCP_Contact__r.AccountId  FROM HCP_Enrollment__c];
        
        EmailTemplateProviderHCPMultiPI hcpMultiPI = new EmailTemplateProviderHCPMultiPI();
        hcpMultiPI.initState(hcpenrollList[0].HCP_Contact__c,
                            hcpenrollList[0].HCP_Contact__r.LastName,
                            hcpenrollList[0].HCP_Contact__r.Language__c,
                            'Default',
                            hcpenrollList[0].HCP_Contact__r.AccountId,
                            'HTML',
                            'Yes');                                     
        
        Test.stopTest();
    }

}