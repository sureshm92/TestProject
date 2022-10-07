@isTest
public class Test_Batch_CreateScreenerResponse {
    
    @IsTest
    static void createScreenerResponse_Test() {

        TestData.loadTestData();

        Test.startTest();

        TestData td = new TestData();
        td.ctp.Link_to_Medical_Record_Review__c = 'https://testmrrsite.com';
        td.ctp.Link_to_Pre_screening__c = 'https://testscreeningsite.com';
        update td.ctp;   
        
        td.pe.Medical_Record_Review_Completed_Date__c = DateTime.now();
        td.pe.MRR_Survey_Results_URL__c = 'Test MRR Response';
        td.pe.Medical_Record_Review_Completed_by__c = td.piContact.Id;
        td.pe.Pre_Screener_Completed_Date__c = DateTime.now();
        td.pe.Pre_Screener_Survey_Response__c = 'Test Prescreener Response';
        td.pe.Pre_Screener_Completed_by__c = td.piContact.Id;
        update td.pe;       

        Database.executeBatch(new Batch_CreateScreener());
        Database.executeBatch(new Batch_CreateScreenerResponse());

        Test.stopTest();

        List<Participant_PrescreenerResponse__c> responseList = [
            SELECT Id FROM Participant_PrescreenerResponse__c WHERE Participant_enrollment__c = :td.pe.Id 
        ];
        system.assertEquals(2, responseList.size());
    } 

    @IsTest
    static void createEPRResponse_Test() {

        TestData.loadTestData();

        Test.startTest();
        
        TestData td = new TestData();
        td.pe.Medical_Record_Review_Completed_Date__c = DateTime.now();
        td.pe.MRR_Survey_Results_URL__c = 'Test MRR Response';
        td.pe.Medical_Record_Review_Status__c = null;
        update td.pe;       

        Database.executeBatch(new Batch_CreateScreenerResponse());

        Test.stopTest();

        List<Participant_PrescreenerResponse__c> responseList = [
            SELECT Id FROM Participant_PrescreenerResponse__c WHERE Participant_enrollment__c = :td.pe.Id 
        ];
        system.assertEquals(1, responseList.size());
    } 
}