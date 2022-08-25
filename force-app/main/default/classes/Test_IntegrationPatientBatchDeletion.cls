@IsTest
public class Test_IntegrationPatientBatchDeletion {
	@TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testIntPatientBatchDel_False() {
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Principal_Investigator__c FROM Study_Site__c Limit 1];
        List<Integration_Patient__c> intPatLst= new List<Integration_Patient__c>();
        for(integer i =0; i<10;i++){
            Integration_Patient__c externalPatient = new Integration_Patient__c();
            externalPatient.External_ID__c = '1~2~3';
            externalPatient.STUDYID__c=testStudySites[0].Clinical_Trial_Profile__c;
            externalPatient.Subject_Status__c = 'Completed';
            externalPatient.Subject_Date__c = Date.today().addDays(1);
            externalPatient.IsDeletedInSDH__c = 'N';  
            intPatLst.add(externalPatient);
        }
        insert intPatLst;
        Test.startTest();
		Database.executeBatch(new IntegrationPatientBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c),5);
        Test.stopTest();
        List<Integration_Patient__c> intParLst=[Select Id,Name FROM Integration_Patient__c where STUDYID__c=:testStudySites[0].Clinical_Trial_Profile__c];
        System.assertEquals(0,intParLst.size());
        
    }
}