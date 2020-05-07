/**
 * Created by Nargiz Mamedova on 5/6/2020.
 */

@IsTest
private class Test_IntegrationTrialMatchTriggerHandler {
    @TestSetup
    static void setup(){
        TestData.loadTestData();
    }

    @IsTest
    static void testBehavior() {
        TestData testData = new TestData();
        Integration_Trial_Match__c newItm = new Integration_Trial_Match__c(
                Protocol_ID__c = testData.ctp.Protocol_ID__c,
                Participant_Enrollment_External_ID__c = testData.pe.External_Key__c,
                Matching_Score__c = 5, Matching_Details__c = 'Details', Matched_Date__c = Date.today(),
                Therapeutic_Area__c = 'Test TA', IsDeleted__c = false, Is_Eligible__c = true
        );
        Integration_Trial_Match__c changedItm = new Integration_Trial_Match__c(
                Protocol_ID__c = testData.ctp.Protocol_ID__c,
                Participant_Enrollment_External_ID__c = testData.pe.External_Key__c,
                Matching_Score__c = 5, Matching_Details__c = 'Details update', Matched_Date__c = Date.today(),
                Therapeutic_Area__c = 'Test TA', IsDeleted__c = false, Is_Eligible__c = true
        );
        Integration_Trial_Match__c deletedItm = new Integration_Trial_Match__c(
                Protocol_ID__c = testData.ctp.Protocol_ID__c,
                Participant_Enrollment_External_ID__c = testData.pe.External_Key__c,
                Matching_Score__c = 5, Matching_Details__c = 'Details update', Matched_Date__c = Date.today(),
                Therapeutic_Area__c = 'Test TA', IsDeleted__c = true, Is_Eligible__c = false
        );

        Test.startTest();
        insert newItm;
        List<Trial_Match__c> tms = [SELECT Id, Matching_Details__c FROM Trial_Match__c];
        System.assertEquals('Details', tms[0].Matching_Details__c);

        insert changedItm;
        tms = [SELECT Id, Matching_Details__c FROM Trial_Match__c];
        System.assertEquals('Details update', tms[0].Matching_Details__c);

        insert deletedItm;
        Test.stopTest();

        tms = [SELECT Id, Matching_Details__c FROM Trial_Match__c];
        System.assert(tms.size() == 0);
    }

    @IsTest
    static void testExceptionExtKey(){
        Boolean isExceptionThrown = false;
        TestData testData = new TestData();
        Integration_Trial_Match__c newItm = new Integration_Trial_Match__c(
                Protocol_ID__c = testData.ctp.Protocol_ID__c,
                Participant_Enrollment_External_ID__c = 'smth',
                Matching_Score__c = 5, Matching_Details__c = 'Details', Matched_Date__c = Date.today(),
                Therapeutic_Area__c = 'Test TA', IsDeleted__c = false, Is_Eligible__c = true
        );

        Test.startTest();
        try{
            insert newItm;
        } catch (DmlException e){
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }

    @IsTest
    static void testExceptionProtId(){
        Boolean isExceptionThrown = false;
        TestData testData = new TestData();
        Integration_Trial_Match__c newItm = new Integration_Trial_Match__c(
                Protocol_ID__c = 'smth',
                Participant_Enrollment_External_ID__c = testData.pe.External_Key__c,
                Matching_Score__c = 5, Matching_Details__c = 'Details', Matched_Date__c = Date.today(),
                Therapeutic_Area__c = 'Test TA', IsDeleted__c = false, Is_Eligible__c = true
        );

        Test.startTest();
        try{
            insert newItm;
        } catch (DmlException e){
            isExceptionThrown = true;
        }
        Test.stopTest();
        System.assert(true, isExceptionThrown);
    }
}