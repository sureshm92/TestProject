/**
 * Created by Denis Z on 01-Jul-19.
 */

trigger IntegrationVisitTrigger on Integration_Visit__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationVisitTriggerHandler.CheckProcessedRecordsHandler.class);
}