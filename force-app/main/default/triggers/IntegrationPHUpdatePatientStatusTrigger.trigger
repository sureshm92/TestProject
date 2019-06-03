/**
 * Created by user on 30-May-19.
 */

trigger IntegrationPHUpdatePatientStatusTrigger on Integration_PH_Update_Patient_Status__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationPHUpdatePatientStatusHandler.UpdatePatientsHandler.class);
}