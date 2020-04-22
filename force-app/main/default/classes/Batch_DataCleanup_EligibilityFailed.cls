/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_DataCleanup_EligibilityFailed implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Participant_Status__c, Non_Enrollment_Reason__c, Last_Status_Changed_Notes__c FROM Participant_Enrollment__c WHERE Participant_Status__c = \'Eligibility Failed\' AND Study_Site__r.Study_Site_Type__c = \'Traditional\'';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        Set<Id> peIds = new Set<Id>();
        List<Participant_Enrollment_Status_History__c> peshToUpdate = new List<Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment__c pe : scope) {
            pe.Participant_Status__c = PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE;
            peIds.add(pe.Id);
        }
        for (Participant_Enrollment_Status_History__c pesh : [
                SELECT Id, Status__c, Reason__c, Notes__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c IN :peIds AND Status__c = :PEStatusState.PE_STATUS_ELIGIBILITY_FAILED
        ]) {
            pesh.Status__c = PEStatusState.PE_STATUS_CONTACTED_NOT_SUITABLE;
            peshToUpdate.add(pesh);
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
        if (!peshToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
            TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
            update peshToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {

    }


}