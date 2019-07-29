/**
 * Refactored by Leonid Bartenev
 */

trigger NationalIDTrigger on National_ID__c (before insert, before update, after insert, after update) {
    TriggerHandlerExecutor.execute(NationalIdTriggerHandler.PrepareCityStateFieldsHandler.class);
}