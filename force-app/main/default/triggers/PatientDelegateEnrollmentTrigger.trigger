trigger PatientDelegateEnrollmentTrigger on Patient_Delegate_Enrollment__c (
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.SetDefaultPatientDelegateStatusHandler.class
    );
    TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.CreateNewAssignmentNotification.class
    );
    TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.CreateReactivatedNotification.class
    );
    TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.CreatePrimaryDelegateForMinor.class
    );
    TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.UpdateDelegateConsent.class
    );
    //Timestamp should not be bypassed when consents are changed
    TriggerHandlerExecutor.execute(
        PatientDelegateEnrolTriggerHandler.UpdateConsentTimeStamps.class
    );
}