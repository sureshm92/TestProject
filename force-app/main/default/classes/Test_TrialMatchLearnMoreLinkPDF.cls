/**
* @author        Enugothula Srinath 
* @date          01/06/2020
* @description   This is a test class which covers the code for TrialMatchLearnMoreLinkPDF. 
-----------------------------------------------------------------------------------------------------------------
Developer                 Date                         Description
-----------------------------------------------------------------------------------------------------------------
Srinath       			01/06/2020      			Initial Version
*/
@isTest
private class Test_TrialMatchLearnMoreLinkPDF {	 
    
    //This method tests the logo Query
    @IsTest
    static void testQuery_getLogFromStaticQuery() {
        Test.startTest();
        Blob logo = [SELECT Body FROM StaticResource WHERE Name = :TrialMatchLearnMoreLinkPDF.IQVIA_LOGO].Body;
        String encodedBody = 'data:image/png;base64,' + EncodingUtil.base64Encode(logo);
        System.assertEquals(
            encodedBody, 
            TrialMatchLearnMoreLinkPDF.getLogoFromStatic(),
            'The encoded body of the logo should match'
        );
        Test.stopTest();
    }
    
    //This method tests CTP query
    @IsTest
    static void testQuery_getCTPLearMoreDetails() {
        Test.startTest();
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(Study_Code_Name__c = 'Test Code', Detailed_Description__c = 'Test Description', Protocol_ID__c = System.now()+'Test');
        insert ctp;
        System.assertEquals(ctp.Detailed_Description__c,TrialMatchLearnMoreLinkPDF.fetchCTPLearnMoreDetails(ctp.Id).Detailed_Description__c,
                            'The description should match');
        System.assertEquals(ctp.Study_Code_Name__c,TrialMatchLearnMoreLinkPDF.fetchCTPLearnMoreDetails(ctp.Id).Study_Code_Name__c,
                            'The Study code name should match');
        Test.stopTest();
    }
    
    //This method tests CTP query - no results
    @IsTest
    static void testQuery_getCTPLearMoreDetails_Negative() {
        Boolean isExceptionThrown = false;
        try{
            TrialMatchLearnMoreLinkPDF.fetchCTPLearnMoreDetails('a1R9E000001UJANUA4');
        } catch (AuraHandledException e){
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }
}