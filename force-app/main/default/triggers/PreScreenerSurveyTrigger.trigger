trigger PreScreenerSurveyTrigger on PreScreener_Survey__c(
    before insert,
    before update,
    after insert,
    before delete,
    after update
) {
    TriggerHandlerExecutor.execute(
        preScreenerTriggerHandler.validatePreScreenerHandlerBeforeInsert.class
    );
}