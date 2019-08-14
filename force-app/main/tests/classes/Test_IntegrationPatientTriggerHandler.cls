@IsTest
private class Test_IntegrationPatientTriggerHandler {

    @IsTest
    static void integration_Test(){
        Account acc = new Account();
        acc.Name = CommunityService.COMMUNITY_PARTICIPANT_ACCOUNT_NAME;
        insert acc;

        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        ParticipantEnrollmentFactory.createParticipantEnrollmentRecords('1','2','3');

        Test.startTest();
        Integration_Patient__c externalPatient = new Integration_Patient__c(
                External_ID__c = '1~2~3',
                Subject_Status__c = 'Completed',
                Subject_Date__c = Date.today().addDays(1),
                IsDeletedInSDH__c = 'N'
        );
        insert externalPatient;

        System.assertEquals('Participation Complete', getEnrollmentStatus());

        externalPatient.IsDeletedInSDH__c = 'N';
        externalPatient.Subject_Status__c = 'Dropped';
        externalPatient.Subject_Date__c = Date.today().addDays(2);
        update externalPatient;

        System.assertEquals('Drop Out', getEnrollmentStatus());

        update externalPatient;
        System.assertEquals(3, [SELECT COUNT() FROM Participant_Enrollment_Status_History__c]);
        Test.stopTest();
    }

    private static String getEnrollmentStatus(){
        Participant_Enrollment__c pe = [
                SELECT  Id,
                        Participant_Status__c
                FROM    Participant_Enrollment__c
                WHERE   External_Key__c = '1~2~3'
        ];
        return pe.Participant_Status__c;
    }
}