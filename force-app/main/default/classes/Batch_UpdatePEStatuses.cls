/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_UpdatePEStatuses implements Database.Batchable<SObject>{
    private Set<String> peIds;

    global Batch_UpdatePEStatuses() {

    }
    global Batch_UpdatePEStatuses(String peId) {
        this.peIds = new Set<String> {peId};
    }
    global Batch_UpdatePEStatuses(Set<String> peIds) {
        this.peIds = peIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Participant_Status__c, Non_Enrollment_Reason__c FROM Participant_Enrollment__c';
        if(peIds != null && !peIds.isEmpty()) {
            queryString += ' WHERE Id IN :peIds';
        }
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        List<Participant_Enrollment__c> peToUpdate = new List<Participant_Enrollment__c>();

        for (Participant_Enrollment__c pe : scope) {
            String status = pe.Participant_Status__c==null?'':pe.Participant_Status__c.toLowerCase();
            String reason = pe.Non_Enrollment_Reason__c==null?'':pe.Non_Enrollment_Reason__c.toLowerCase();
            String newStatus = StatusesUpdateBatchHelper.getUpdatedStatus(status, reason);
            String newReason = StatusesUpdateBatchHelper.getUpdatedReason(status, reason);
            if(newStatus != null) pe.Participant_Status__c = newStatus;
            if(newReason != null) pe.Non_Enrollment_Reason__c = newReason;
            if(newStatus != null || newReason != null) {
                peToUpdate.add(pe);
            }
        }
        if(!peToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class);
            TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.SendEmailIfSSWasChanged.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateParticipantForDelegateHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class);

            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class);
            TriggerHandlerExecutor.bypassHandler(PENotificationTriggerHandler.CreateNotificationHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class);
            update peToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {

    }

}