trigger CTCTrigger on CTC__c (before update, after insert, after delete) {

    TriggerHandlerExecutor.execute(CTCTriggerHandler.class);
}
