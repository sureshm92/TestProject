/**
 * Created by user on 08-Jul-19.
 */

trigger IntegrationVisitResultTrigger on Integration_VisitResult__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationVisitResultTriggerHandler.CheckProcessedRecordsHandler.class);
}