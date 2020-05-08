/**
 * Created by D.Yasinskyi on 26.04.2018
 * Refactored by Leonid Bartenev
 */

trigger ParticipantEnrollmentTrigger on Participant_Enrollment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(PETriggerHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
    TriggerHandlerExecutor.execute(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateParticipantForDelegateHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
     //TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CheckInitialVisitActivities.class);

    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
    //TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
    TriggerHandlerExecutor.execute(PENotificationTriggerHandler.CreateNotificationHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
    TriggerHandlerExecutor.execute(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
   
}