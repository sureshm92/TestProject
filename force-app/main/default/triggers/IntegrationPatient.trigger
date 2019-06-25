/**
 * Created by Denis Z on 17-Jun-19.
 */

trigger IntegrationPatient on Integration_Patient__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationPatientTriggerHandler.UpdatePatientsHandler.class);
}