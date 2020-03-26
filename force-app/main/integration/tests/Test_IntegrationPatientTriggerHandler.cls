@IsTest
private class Test_IntegrationPatientTriggerHandler {

    @TestSetup
    static void setup() {
        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;
        ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');
    }

    @IsTest
    static void integration_Test(){
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);

        Integration_Patient__c externalPatient = new Integration_Patient__c();
        externalPatient.External_ID__c = '1~2~3';
        externalPatient.Subject_Status__c = 'Completed';
        externalPatient.Subject_Date__c = Date.today().addDays(1);
        externalPatient.IsDeletedInSDH__c = 'N';

        Test.startTest();
        insert externalPatient;
        System.assertEquals('Participation Complete', getPEStatus());
        Test.stopTest();
    }

    private static String getPEStatus(){
        Participant_Enrollment__c pe = [
                SELECT  Id,
                        Participant_Status__c
                FROM    Participant_Enrollment__c
                WHERE   External_Key__c = '1~2~3'
        ];
        return pe.Participant_Status__c;
    }
}