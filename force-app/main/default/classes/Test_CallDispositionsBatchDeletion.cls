@IsTest
public class Test_CallDispositionsBatchDeletion {
    @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testCallDisBatchDeletion() {                
        List<Study_Site__c> testStudySites = [SELECT Id,Clinical_Trial_Profile__c,Principal_Investigator__c FROM Study_Site__c Limit 1];        
        List<Call_Dispositions__c> lstCD =new  List<Call_Dispositions__c>();
        for(integer i =0; i<=20;i++){
            Call_Dispositions__c cd = new Call_Dispositions__c();
            cd.Study_Site__c = testStudySites[0].ID;
            cd.caller__c = testStudySites[0].Principal_Investigator__c;
            cd.Call_Category__c = 'No Answer';   
            lstCD.add(cd);
        }
        insert lstCD;
        Test.startTest();
		Database.executeBatch(new CallDispositionsBatchDeletion(testStudySites[0].Clinical_Trial_Profile__c),5);
        Test.stopTest();
        List<Call_Dispositions__c> callLst=[Select Id,Name FROM Call_Dispositions__c where Study_Site__c in:[select id from Study_Site__c where Clinical_Trial_Profile__c=:testStudySites[0].Clinical_Trial_Profile__c]];
        System.assertEquals(0,callLst.size());
    }
}