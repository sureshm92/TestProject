@IsTest
private class Test_IntegrationPatientTriggerHandler {

    @TestSetup
    static void setup() {
        ParticipantEnrollmentFactory.createParticipantStudyEnrollmentRecords('1',2,3,3);
    }

    @IsTest
    static void integration_Test(){
        Integration_Patient__c externalPatient = new Integration_Patient__c();
        externalPatient.External_ID__c = '1~2~3';
        externalPatient.Subject_Status__c = 'Completed';
        Test.startTest();
        insert externalPatient;
        System.assertEquals('Participation Complete', getPseStatus());
        externalPatient.IsDeletedInSDH__c = 'N';
        externalPatient.Subject_Status__c = 'Dropped';
        update externalPatient;
        System.assertEquals('Drop Out', getPseStatus());
        Test.stopTest();
    }

    private static String getPseStatus(){
        Participant_Study_Enrollment__c pse = [
                SELECT  Id,
                        Status__c
                FROM    Participant_Study_Enrollment__c
                WHERE   External_Key__c = '1~2~3'
        ];
        return pse.Status__c;
    }
}