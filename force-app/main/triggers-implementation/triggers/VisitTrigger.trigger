/**
 * Created by Leonid Bartenev
 */

trigger VisitTrigger on Visit__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(VisitTriggerHandler.DeletePatientVisitOnVisitDeletionHandler.class);
    TriggerHandlerExecutor.execute(VisitTriggerHandler.InsertPatientVisitOnVisitInsertionHandler.class);
    TriggerHandlerExecutor.execute(VisitTriggerHandler.UpdateExistingPatientVisits.class);
}