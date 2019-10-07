/**
 * Created by Leonid Bartenev
 */

trigger TranslationTrigger on Translation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(TranslationTriggerHandler.CheckFieldsConsistencyHandler.class);
}