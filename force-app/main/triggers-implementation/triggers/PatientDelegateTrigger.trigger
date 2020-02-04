/**
 * Created by Leonid Bartenev
 */

trigger PatientDelegateTrigger on Patient_Delegate__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    TriggerHandlerExecutor.execute(PatientDelegateTriggerHandler.SetDefaultPatientDelegateStatus.class);
    TriggerHandlerExecutor.execute(PatientDelegateTriggerHandler.DeActivePatientDelegateUser.class);
    TriggerHandlerExecutor.execute(PatientDelegateTriggerHandler.SendNotificationForNewDelegate.class);

}