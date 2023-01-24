/**
 * Created by D.Yasinskyi on 26.04.2018
 * Refactored by Leonid Bartenev
 */

trigger ParticipantEnrollmentTrigger on Participant_Enrollment__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerHandlerExecutor.execute(PETriggerHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
    );
    TriggerHandlerExecutor.execute(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
    );
    /*For Welcome Msg -- Added by Anitha*/
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.createNotifications.class);
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
    );
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
    TriggerHandlerExecutor.execute(PENotificationTriggerHandler.CreateNotificationHandler.class);
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
    );
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
    );
    /** 
     * Logic moved to Screener response from PE due to multi screener implementation
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
    );
    **/
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SendFOVtoAPI.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.UnenrollorCancelPer.class);
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.UpdateParticipantInitialVisit.class
    );
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateMissingStatuses.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.EcoaEvents.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.DefaultEcoaTask.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.UpdatePatientConsent.class);
    TriggerHandlerExecutor.execute(
        ParticipantEnrollmentTriggerHandler.StudyConsentTimestamps.class
    );
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.UpdateInitialVisits.class);

}
