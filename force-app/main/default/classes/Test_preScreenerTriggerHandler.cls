@isTest
public class Test_preScreenerTriggerHandler {
    
     @IsTest
    static void testSurveyInsertWithSameName() { 
        TestData.loadTestData(); 
        Test.startTest(); 
        TestData td = new TestData();
        td.ctp.Link_to_Medical_Record_Review__c = 'https://testmrrsite.com';
        td.ctp.Link_to_Pre_screening__c = 'https://testscreeningsite.com';
        update td.ctp;    
        List<PreScreener_Survey__c> lstPrescreenerSurvey = new list<PreScreener_Survey__c> ();
        PreScreener_Survey__c objPrescreener = new PreScreener_Survey__c();
        objPrescreener.Study__c = td.ctp.Id;
        objPrescreener.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener.MRR__c = true;
        objPrescreener.Primary__c = true;
        objPrescreener.Survey_Name__c ='testSurvey1';
        insert objPrescreener;
        PreScreener_Survey__c objPrescreener2 = new PreScreener_Survey__c();
        objPrescreener2.Study__c = td.ctp.Id;
        objPrescreener2.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener2.MRR__c = false;
        objPrescreener2.Primary__c = true;
        objPrescreener2.Survey_Name__c ='testSurvey1';
        lstPrescreenerSurvey.add(objPrescreener2);
        try{
        insert objPrescreener2;
        }
        catch(Exception ex)
        {
            String strErrorMessage = ex.getMessage();
            system.assert(strErrorMessage.contains(System.Label.SurveyName_Error));
         }
        
        
        Test.stopTest();
        
    } 
      @IsTest
    static void testSurveyupdateMRR() { 
        TestData.loadTestData(); 
        Test.startTest(); 
        TestData td = new TestData();
        td.ctp.Link_to_Medical_Record_Review__c = 'https://testmrrsite.com';
        td.ctp.Link_to_Pre_screening__c = 'https://testscreeningsite.com';
        update td.ctp;    
        List<PreScreener_Survey__c> lstPrescreenerSurvey = new list<PreScreener_Survey__c> ();
        PreScreener_Survey__c objPrescreener = new PreScreener_Survey__c();
        objPrescreener.Study__c = td.ctp.Id;
        objPrescreener.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener.MRR__c = true;
        objPrescreener.Primary__c = true;
        objPrescreener.Survey_Name__c ='testSurvey1';
        lstPrescreenerSurvey.add(objPrescreener);
       // insert objPrescreener;
        PreScreener_Survey__c objPrescreener2 = new PreScreener_Survey__c();
        objPrescreener2.Study__c = td.ctp.Id;
        objPrescreener2.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener2.MRR__c = false;
        objPrescreener2.Primary__c = true;
        objPrescreener2.Survey_Name__c ='testSurvey2';
        lstPrescreenerSurvey.add(objPrescreener2);
       // insert objPrescreener2;
        insert lstPrescreenerSurvey;
        
        try{
            objPrescreener2.MRR__c = true;
        update objPrescreener2;
        }
        catch(Exception ex)
        {
            String strErrorMessage = ex.getMessage();
            system.assert(strErrorMessage.contains(System.Label.MRR_Error));
         }
        Test.stopTest();
    } 
     @IsTest
    static void testSurveyupdatePreScreener() { 
        TestData.loadTestData(); 
        Test.startTest(); 
        TestData td = new TestData();
        td.ctp.Link_to_Medical_Record_Review__c = 'https://testmrrsite.com';
        td.ctp.Link_to_Pre_screening__c = 'https://testscreeningsite.com';
        update td.ctp;    
        List<PreScreener_Survey__c> lstPrescreenerSurvey = new list<PreScreener_Survey__c> ();
        PreScreener_Survey__c objPrescreener = new PreScreener_Survey__c();
        objPrescreener.Study__c = td.ctp.Id;
        objPrescreener.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener.MRR__c = false;
        objPrescreener.Prescreener__c = true;
        objPrescreener.Primary__c = true;
        objPrescreener.Survey_Name__c ='testSurvey1';
        lstPrescreenerSurvey.add(objPrescreener);
       // insert objPrescreener;
        PreScreener_Survey__c objPrescreener2 = new PreScreener_Survey__c();
        objPrescreener2.Study__c = td.ctp.Id;
        objPrescreener2.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener2.MRR__c = false;
        objPrescreener2.Primary__c = true;
        objPrescreener2.Survey_Name__c ='testSurvey2';
        lstPrescreenerSurvey.add(objPrescreener2);
       // insert objPrescreener2;
        insert lstPrescreenerSurvey;
        
        try{
            objPrescreener2.Prescreener__c = true; 
        update objPrescreener2;
        }
        catch(Exception ex)
        {
            String strErrorMessage = ex.getMessage();
            system.assert(strErrorMessage.contains(System.Label.PreScreener_Error));
         }
        Test.stopTest();
    }
     @IsTest
    static void testSurveyupdateScreenerName() { 
        TestData.loadTestData(); 
        Test.startTest(); 
        TestData td = new TestData();
        td.ctp.Link_to_Medical_Record_Review__c = 'https://testmrrsite.com';
        td.ctp.Link_to_Pre_screening__c = 'https://testscreeningsite.com';
        update td.ctp;    
        List<PreScreener_Survey__c> lstPrescreenerSurvey = new list<PreScreener_Survey__c> ();
        PreScreener_Survey__c objPrescreener = new PreScreener_Survey__c();
        objPrescreener.Study__c = td.ctp.Id;
        objPrescreener.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener.MRR__c = false;
        objPrescreener.Prescreener__c = true;
        objPrescreener.Primary__c = true;
        objPrescreener.Survey_Name__c ='testSurvey1';
        lstPrescreenerSurvey.add(objPrescreener);
       // insert objPrescreener;
        PreScreener_Survey__c objPrescreener2 = new PreScreener_Survey__c();
        objPrescreener2.Study__c = td.ctp.Id;
        objPrescreener2.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener2.MRR__c = false;
        objPrescreener2.Primary__c = true;
        objPrescreener2.Survey_Name__c ='testSurvey2';
        lstPrescreenerSurvey.add(objPrescreener2);
       // insert objPrescreener2;
        insert lstPrescreenerSurvey;
        
        try{
            objPrescreener2.Survey_Name__c = 'testSurvey1'; 
        update objPrescreener2;
        }
        catch(Exception ex)
        {
            String strErrorMessage = ex.getMessage();
            system.assert(strErrorMessage.contains(System.Label.SurveyName_Error));
         }
        Test.stopTest();
    }
     @IsTest
    static void testSurveyInsertPrescreenerSurvey() { 
        TestData.loadTestData(); 
        Test.startTest(); 
        TestData td = new TestData();
        td.ctp.Link_to_Medical_Record_Review__c = 'https://testmrrsite.com';
        td.ctp.Link_to_Pre_screening__c = 'https://testscreeningsite.com';
        update td.ctp;    
        List<PreScreener_Survey__c> lstPrescreenerSurvey = new list<PreScreener_Survey__c> ();
        PreScreener_Survey__c objPrescreener = new PreScreener_Survey__c();
        objPrescreener.Study__c = td.ctp.Id;
        objPrescreener.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener.MRR__c = false;
        objPrescreener.Prescreener__c = true;
        objPrescreener.Primary__c = true;
        objPrescreener.Survey_Name__c ='testSurvey1';
        insert objPrescreener;
        PreScreener_Survey__c objPrescreener2 = new PreScreener_Survey__c();
        objPrescreener2.Study__c = td.ctp.Id;
        objPrescreener2.Link_to_Pre_screening__c = 'https://testmrrsite.com';
        objPrescreener2.MRR__c = false;
        objPrescreener2.Primary__c = true;
        objPrescreener2.Survey_Name__c ='testSurvey2';  
        objPrescreener2.Prescreener__c = true;
        
        try{
             insert objPrescreener2;
        }
        catch(Exception ex)
        {
            String strErrorMessage = ex.getMessage();
            system.assert(strErrorMessage.contains(System.Label.PreScreener_Error));
         }
        Test.stopTest();
    }

}