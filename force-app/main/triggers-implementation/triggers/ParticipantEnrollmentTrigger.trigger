/**
 * Created by D.Yasinskyi on 26.04.2018
 * Refactored by Leonid Bartenev
 */

trigger ParticipantEnrollmentTrigger on Participant_Enrollment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(PETriggerHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SetParticipantStatusHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
    TriggerHandlerExecutor.execute(NotificationTriggerHandler.SendEmailIfSSWasChanged.class);

    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SendDropOutEmailHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SetCurrentEnrollmentHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.UpdatePEHistoryOnAutoAcceptedHandler.class);
    TriggerHandlerExecutor.execute(PENotificationTriggerHandler.CreateNotificationHandler.class);
}