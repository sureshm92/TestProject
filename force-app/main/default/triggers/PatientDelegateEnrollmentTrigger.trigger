trigger PatientDelegateEnrollmentTrigger on Patient_Delegate_Enrollment__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    /*TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.CreateNewAssignmentNotification.class
    );*/
    /*TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.CreateReactivatedNotification.class
    );*/
}