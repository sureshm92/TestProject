/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_UpdatePESHStatuses implements Database.Batchable<SObject>{
    private Set<String> peIds;

    global Batch_UpdatePESHStatuses() {

    }
    global Batch_UpdatePESHStatuses(String peId) {
        this.peIds = new Set<String> {peId};
    }
    global Batch_UpdatePESHStatuses(Set<String> peIds) {
        this.peIds = peIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Status__c, Reason__c, Notes__c FROM Participant_Enrollment_Status_History__c';
        if(peIds != null && !peIds.isEmpty()) {
            queryString += ' WHERE ParticipantEnrollment__c IN :peIds';
        }
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment_Status_History__c> scope) {
        List<Participant_Enrollment_Status_History__c> peshToUpdate = new List<Participant_Enrollment_Status_History__c>();

        for (Participant_Enrollment_Status_History__c pesh : scope) {
            String status = pesh.Status__c==null?'':pesh.Status__c.toLowerCase();
            String reason = pesh.Reason__c==null?'':pesh.Reason__c.toLowerCase();
            String newStatus = StatusesUpdateBatchHelper.getUpdatedStatus(status, reason);
            String newReason = StatusesUpdateBatchHelper.getUpdatedReason(status, reason);
            String newNotes = StatusesUpdateBatchHelper.getUpdatedNotes(status, reason);
            if(newStatus != null) pesh.Status__c = newStatus;
            if(newReason != null) pesh.Reason__c = newReason;
            if(newNotes != null) pesh.Notes__c = newNotes;
            if(newStatus != null || newReason != null) {
                peshToUpdate.add(pesh);
            }
        }
        if(!peshToUpdate.isEmpty()) {
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