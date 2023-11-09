@IsTest
public  class Test_PERScreenerResponseDeletionBatch {
   @TestSetup
    static void init(){
        TestData.loadTestData();
    }
    @IsTest
    static void testScreenerResponse_False() {
         
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test Screener');
        insert studClTest;
          List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
         screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = peRecs[0].Clinical_Trial_Profile__c,
            Survey_Name__c = 'Medical Record Review'
        ));
         insert screenerList;
          List<Participant_PrescreenerResponse__c> lstScreenerResponse = new List<Participant_PrescreenerResponse__c>();
        for(Participant_Enrollment__c peRec:peRecs){
            Participant_PrescreenerResponse__c response = new Participant_PrescreenerResponse__c(
                PreScreener_Survey__c = screenerList[0].Id,
              Participant_enrollment__c = peRec.Id,
                Screener_Response__c = 'Test Response',
              MRR__c = true,
              Status__c = 'Pass'
            );
            lstScreenerResponse.add(response);
        }
        insert lstScreenerResponse;
        Test.startTest();
		Database.executeBatch(new PERScreenerResponseDeletionBatch(peRecs[0].Clinical_Trial_Profile__c),10);
        Test.stopTest();
        List<Participant_PrescreenerResponse__c> perScreenerList=[SELECT Id from Participant_PrescreenerResponse__c where Participant_Enrollment__c in:peRecs limit 10];
        System.assertEquals(2,perScreenerList.size());
    }
     @IsTest
    static void testScreenerResponse_true() {
         
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test Screener');
        insert studClTest;
          List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
         screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = peRecs[0].Clinical_Trial_Profile__c,
            Survey_Name__c = 'Medical Record Review'
        ));
         insert screenerList;
          List<Participant_PrescreenerResponse__c> lstScreenerResponse = new List<Participant_PrescreenerResponse__c>();
        for(Participant_Enrollment__c peRec:peRecs){
            Participant_PrescreenerResponse__c response = new Participant_PrescreenerResponse__c(
                PreScreener_Survey__c = screenerList[0].Id,
              Participant_enrollment__c = peRec.Id,
                Screener_Response__c = 'Test Response',
              MRR__c = true,
              Status__c = 'Pass'
            );
            lstScreenerResponse.add(response);
        }
        insert lstScreenerResponse;
        Test.startTest();
		Database.executeBatch(new PERScreenerResponseDeletionBatch(peRecs[0].Clinical_Trial_Profile__c,true),10);
        Test.stopTest();
        List<Participant_PrescreenerResponse__c> perScreenerList=[SELECT Id from Participant_PrescreenerResponse__c where Participant_Enrollment__c in:peRecs limit 10];
        System.assertEquals(0,perScreenerList.size());
    }
     @IsTest
    static void testScreenerResponse_BlankCTPId() {
         
        List<Participant_Enrollment__c> peRecs= [SELECT Id,Clinical_Trial_Profile__c FROM Participant_Enrollment__c limit 2];
        Study_Closure__c studClTest= new Study_Closure__c(Clinical_Trial_Profile_Id__c=peRecs[0].Clinical_Trial_Profile__c,Clinical_Trial_Profile_Name__c='test Screener');
        insert studClTest;
          List<PreScreener_Survey__c> screenerList = new List<PreScreener_Survey__c>();
         screenerList.add(new PreScreener_Survey__c(
            Link_to_Pre_screening__c = 'https://link.test',
            MRR__c = true,
            ProviderName__c = 'surveygizmo',
            Study__c = peRecs[0].Clinical_Trial_Profile__c,
            Survey_Name__c = 'Medical Record Review'
        ));
         insert screenerList;
          List<Participant_PrescreenerResponse__c> lstScreenerResponse = new List<Participant_PrescreenerResponse__c>();
        for(Participant_Enrollment__c peRec:peRecs){
            Participant_PrescreenerResponse__c response = new Participant_PrescreenerResponse__c(
                PreScreener_Survey__c = screenerList[0].Id,
              Participant_enrollment__c = peRec.Id,
                Screener_Response__c = 'Test Response',
              MRR__c = true,
              Status__c = 'Pass'
            );
            lstScreenerResponse.add(response);
        }
        insert lstScreenerResponse;
        Test.startTest();
		Database.executeBatch(new PERScreenerResponseDeletionBatch(''),10);
        Test.stopTest();
        List<Participant_PrescreenerResponse__c> perScreenerList=[SELECT Id from Participant_PrescreenerResponse__c where Participant_Enrollment__c in:peRecs limit 10];
        System.assertEquals(2,perScreenerList.size());
    }
}