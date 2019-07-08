/**
 * Created by user on 04-Jul-19.
 */

trigger PatientVisitResultTrigger on Integration_VisitResult__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(PatientVisitResultTriggerHandler.UpdateVisitResults.class);
}