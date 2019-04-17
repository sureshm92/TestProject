trigger TherapeuticAreaTrigger on Therapeutic_Area__c (after insert, after update) {

    TriggerHandlerExecutor.execute(TherapeuticAreaTriggerHandler.class);
}