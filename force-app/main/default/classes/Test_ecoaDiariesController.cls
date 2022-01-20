@isTest
private class Test_ecoaDiariesController {
    static user thisUser;   
    @testSetup
    static void setUp(){
        TestData.loadTestData();
        Clinical_Trial_Profile__c ctp = [select id, Study_GUID__c from Clinical_Trial_Profile__c limit 1];
        ctp.Study_GUID__c = 'testguid123';
        update ctp;
    }
    
    @isTest static void ecoaTest() {
        Test.startTest(); 
        TestData obj = new TestData();
        thisUser= obj.participantUser; 
        System.runAs(thisUser){
            ecoaDiariesController.getToken();
        } 
        Test.StopTest();
    }
}     
  