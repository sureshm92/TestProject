/**
 * Created by Leonid Bartenev
 */

trigger IntegrationPatientTrigger on Integration_Patient__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationPatientTriggerHandler.UpdatePatientsHandler.class);
}