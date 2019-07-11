/**
 * Created by Denis Z on 01-Jul-19.
 */

trigger PatientVisitTrigger on Patient_Visit__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(PatientVisitTriggerHandler.UpdateMissedVisits.class);
}