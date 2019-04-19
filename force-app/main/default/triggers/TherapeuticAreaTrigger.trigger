trigger TherapeuticAreaTrigger on Therapeutic_Area__c (after update, before delete) {

    TriggerHandlerExecutor.execute(TherapeuticAreaTriggerHandler.class);
}