/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_DataCleanup_Received implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Participant_Status__c, Non_Enrollment_Reason__c, Last_Status_Changed_Notes__c FROM Participant_Enrollment__c WHERE Participant_Status__c = \'Referral Accepted\' AND Study_Site__c != NULL';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        for (Participant_Enrollment__c pe : scope) {
            pe.Participant_Status__c = PEStatusState.PE_STATUS_RECEIVED;
        }
        TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
        TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
        update scope;
    }

    global void finish(Database.BatchableContext bc) {

    }


}