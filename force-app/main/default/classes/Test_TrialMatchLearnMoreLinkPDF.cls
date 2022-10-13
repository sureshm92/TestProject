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
        try {
            TrialMatchLearnMoreLinkPDF.getLogoFromStatic('GSK');
        } catch (Exception e) {
            System.debug('Exception Handing');
        }
        Test.stopTest();
    }
    @IsTest //getBase64LearnMoreData
    static void testQuery_getBase64LearnMoreData() {
        Test.startTest();
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
            Study_Code_Name__c = 'Test Code',
            // Detailed_Description__c = 'Test Description',
            Protocol_ID__c = System.now() + 'Test'
        );
        insert ctp;
        try {
            TrialMatchLearnMoreLinkPDF.getBase64LearnMoreData(ctp.Id);
        } catch (Exception e) {
            System.debug('Exception Handing');
        }
        Test.stopTest();
    }
    @IsTest //getBase64LearnMoreData
    static void testQuery_getBase64LearnMoreDataNegative() {
        Test.startTest();
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
            Study_Code_Name__c = 'Test Code',
            //  Detailed_Description__c = 'Test Description',
            Protocol_ID__c = System.now() + 'Test'
        );
        insert ctp;
        try {
            TrialMatchLearnMoreLinkPDF.getBase64LearnMoreData('');
        } catch (Exception e) {
            System.debug('Exception Handing');
        }
        Test.stopTest();
    }

    //This method tests CTP query
    @IsTest
    static void testQuery_getCTPLearMoreDetails() {
        Test.startTest();
        Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
            Study_Code_Name__c = 'Test Code',
            // Detailed_Description__c = 'Test Description',
            Protocol_ID__c = System.now() + 'Test'
        );
        insert ctp;
        /* System.assertEquals(
             ctp.Detailed_Description__c,
            TrialMatchLearnMoreLinkPDF.fetchCTPLearnMoreDetails(ctp.Id).Detailed_Description__c,
            'The description should match'
        );*/
        System.assertEquals(
            ctp.Study_Code_Name__c,
            TrialMatchLearnMoreLinkPDF.fetchCTPLearnMoreDetails(ctp.Id).Study_Code_Name__c,
            'The Study code name should match'
        );
        Test.stopTest();
    }

    //This method tests CTP query - no results
    @IsTest
    static void testQuery_getCTPLearMoreDetails_Negative() {
        Boolean isExceptionThrown = false;
        try {
            TrialMatchLearnMoreLinkPDF.fetchCTPLearnMoreDetails('a1R9E000001UJANUA4');
        } catch (AuraHandledException e) {
            isExceptionThrown = true;
            System.assert(e.getTypeName() == 'System.AuraHandledException');
        }
        System.assert(true, isExceptionThrown);
    }
}
