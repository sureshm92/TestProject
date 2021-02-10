@isTest
private class Test_FetchCallDispositions {
    @TestSetup
    static void setup() {
        Test.startTest();
        TestData.loadTestData(); 
        Test.stopTest();
    }
     
    @IsTest
    static void testgettodaydate() {                
        List<Study_Site__c> testStudySites = [SELECT Id, Principal_Investigator__c FROM Study_Site__c Limit 1];        
        List<Call_Dispositions__c> lstCD =new  List<Call_Dispositions__c>();
        for(integer i =0; i<=10;i++){
            Call_Dispositions__c cd = new Call_Dispositions__c();
            cd.Study_Site__c = testStudySites[0].ID;
            cd.caller__c = testStudySites[0].Principal_Investigator__c;
            cd.Call_Category__c = 'No Answer';   
            lstCD.add(cd);
        }
           insert lstCD;
        
        Test.startTest();         
        TestData tstData = new TestData();
        System.runAs(tstData.piUser) 
        {
          FetchCallDispositions.gettodaydate();          
          FetchCallDispositions.getcalls(12, testStudySites[0].Id);            
        }          
        Test.stopTest();
    }
}