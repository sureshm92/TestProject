trigger ParticipantScreenerResponseTrigger on Participant_PrescreenerResponse__c(
    after insert,
    after update
) {
    TriggerHandlerExecutor.execute(
        ScreenerResponseTriggerHandler.CheckReimbursableActivities.class
    );
}