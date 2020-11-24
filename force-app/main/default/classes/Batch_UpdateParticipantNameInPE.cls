global without sharing class Batch_UpdateParticipantNameInPE implements Database.Batchable<SObject> {
    global Batch_UpdateParticipantNameInPE() {
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String queryString =
            'SELECT Id, ' +
            'Participant__c, ' +
            'Participant_Name__c, ' +
            'Participant_Surname__c, ' +
            'Participant__r.First_Name__c, ' +
            'Participant__r.Last_Name__c ' +
            'FROM Participant_Enrollment__c ' +
            'WHERE Participant__c != NULL ';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> scope) {
        List<Participant_Enrollment__c> peToUpdate = new List<Participant_Enrollment__c>();

        for (Participant_Enrollment__c pe : scope) {
            if (
                String.isEmpty(pe.Participant_Name__c) || String.isEmpty(pe.Participant_Surname__c)
            ) {
                pe.Participant_Name__c = pe.Participant__r.First_Name__c;
                pe.Participant_Surname__c = pe.Participant__r.Last_Name__c;
                peToUpdate.add(pe);
            }
        }
        if (!peToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(PETriggerHandler.class);
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.SetSourceTypeHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusTrackingHistoryRecordsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateStatusBasedInvitations.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.SendEmailIfSSWasChanged.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckVisitPlanFromStudySiteHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.UpdateParticipantState.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.DeactivateDeceasedUsersHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateVisitsScheduleHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.HideSurveyTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                PENotificationTriggerHandler.CreateNotificationHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CompleteEnrollmentTasks.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.StudySiteHistoryHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentTriggerHandler.CheckReimbursableActivities.class
            );
            update peToUpdate;
        }
    }

    global void finish(Database.BatchableContext bc) {
    }
}
