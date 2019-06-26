@IsTest
public class Test_TrialSurveyTriggerHandler {

    @TestSetup
    static void setup() {

    }

    @IsTest
    static void integration_Test() {


        List<Trial_Survey__c> surveys = new List<Trial_Survey__c>();

        Test.startTest();
        delete surveys;
        Test.stopTest();
    }
}