@isTest
public class Test_Batch_CreateScreener {
    
    @IsTest
    static void CreateScreener_Test() {

        TestData.loadTestData();
        Test.startTest();

        TestData td = new TestData();
        td.ctp.Link_to_Medical_Record_Review__c = 'https://testmrrsite.com';
        td.ctp.Link_to_Pre_screening__c = 'https://testscreeningsite.com';
        update td.ctp;       

        Database.executeBatch(new Batch_CreateScreener());

        Test.stopTest();

        List<PreScreener_Survey__c> surveyList = [
            SELECT Id FROM PreScreener_Survey__c WHERE Study__c = :td.ctp.Id 
        ];
        system.assertEquals(2, surveyList.size());
    } 
}