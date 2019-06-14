/**
 * Created Denis Z user on 13-Jun-19.
 */

trigger IntegrationPatientTrigger on Integration_Patients__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationPatientTriggerHandler.UpdatePatientsHandler.class);
}