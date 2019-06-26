@IsTest
private class Test_IntegrationPatientTriggerHandler {

    @TestSetup
    static void setup() {

    }

    @IsTest
    static void integration_Test() {

        List<Integration_Patient__c> patients = new List<Integration_Patient__c>{
                new Integration_Patient__c(External_ID__c = '123')
        };

        Test.startTest();
        insert patients;
        Test.stopTest();
    }
}