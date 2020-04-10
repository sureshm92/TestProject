/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_UpdateParticipantInitialVisitFlag implements Database.Batchable<SObject> {

    global Batch_UpdateParticipantInitialVisitFlag() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Participant_Status__c, Initial_visit_occurred_flag__c, Clinical_Trial_Profile__r.Initial_Visit_Required__c FROM Participant_Enrollment__c WHERE Clinical_Trial_Profile__r.Initial_Visit_Required__c = TRUE';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        List<Participant_Enrollment__c> peToUpdate = new List<Participant_Enrollment__c>();

        for (Participant_Enrollment__c pe : scope) {
            if(PEStatusState.PE_ORDERED_STATUSES.get(pe.Participant_Status__c) != null && PEStatusState.PE_ORDERED_STATUSES.get(pe.Participant_Status__c) > PEStatusState.PE_ORDERED_STATUSES.get(PEStatusState.PE_STATUS_SUCCESSFULLY_CONTACTED)){
                pe.Initial_visit_occurred_flag__c = true;
                pe.Informed_Consent__c = true;
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