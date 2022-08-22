/**
 * Created by Kryvolap
 */

trigger ParticipantEnrollmentStatusHistoryTrigger on Participant_Enrollment_Status_History__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerHandlerExecutor.execute(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class);
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentSHTriggerHandler.UpdatePERReEngaged.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentSHTriggerHandler.UpdateLastChangedAdditionalNotes.class
    );
}