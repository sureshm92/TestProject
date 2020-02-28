/**
 * Created by Leonid Bartenev
 */

trigger PatientDelegateTrigger on Patient_Delegate__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerHandlerExecutor.execute(PatientDelegateTriggerHandler.SetDefaultPatientDelegateStatusHandler.class);
    TriggerHandlerExecutor.execute(PatientDelegateTriggerHandler.UpdateUserStatusHandler.class);
    TriggerHandlerExecutor.execute(PatientDelegateTriggerHandler.UpdatePermissionSetAssignments.class);

}