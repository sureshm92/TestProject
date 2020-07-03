/**
 * Created by Alexey Moseev on 7/3/20.
 */

@IsTest
private class Test_Batch_CreatePushNotificationForPE {

    @TestSetup
    static void init() {
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);

        Test.startTest();
        TestData.loadTestData();
        Test.stopTest();
    }

    @IsTest
    static void testBatchCreatePushNotificationForPE() {
        Test.startTest();
        List<Participant_Enrollment__c> participantEnrollments = [SELECT Id, Participant_Status__c
                                                                  FROM Participant_Enrollment__c];
        participantEnrollments[0].Participant_Status__c = PEStatusState.PE_STATUS_CONTACT_ATTEMPTED;
        update participantEnrollments;
        participantEnrollments[0].Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
        update participantEnrollments;

        Batch_CreatePushNotificationForPE batchForPE = new Batch_CreatePushNotificationForPE();
        Database.executeBatch(batchForPE);
        batchForPE.getBatchDescription();
        batchForPE.getRecommendedIntervalMode();
        batchForPE.getRecommendedRelaunchInterval();
        batchForPE.getType();
        Test.stopTest();
    }

}