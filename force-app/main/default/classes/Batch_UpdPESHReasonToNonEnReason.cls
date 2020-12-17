/**
 * Created by Krishna Mahto.
 * This is one time batch which will update Reason field to newly created non-Enrollment Reason field on
 * PESH for historical Data.
 */
global class Batch_UpdPESHReasonToNonEnReason implements Database.Batchable<SObject> {


   global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id,Reason__c, Non_Enrollment_Reason__c FROM Participant_Enrollment_Status_History__c';
        
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc,List<Participant_Enrollment_Status_History__c> scope) {
        List<Participant_Enrollment_Status_History__c> peshToUpdate = new List<Participant_Enrollment_Status_History__c>();
        for (Participant_Enrollment_Status_History__c pesh : scope) {
            pesh.Non_Enrollment_Reason__c = pesh.Reason__c;
            peshToUpdate.add(pesh);
        }
        if (!peshToUpdate.isEmpty()) {
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.CreateWelcomeToStudyAlertHandler.class
            );
            TriggerHandlerExecutor.bypassHandler(
                ParticipantEnrollmentSHTriggerHandler.UpdateLastChangedAdditionalNotes.class
            ); 
            Database.Update(peshToUpdate, false);
        }
    }

    global void finish(Database.BatchableContext bc) {
    }
}