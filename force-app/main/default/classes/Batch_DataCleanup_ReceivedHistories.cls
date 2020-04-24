/**
 * Created by Andrii Kryvolap.
 */

global without sharing class Batch_DataCleanup_ReceivedHistories implements Database.Batchable<SObject> {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'SELECT Id, Status__c FROM Participant_Enrollment_Status_History__c WHERE Status__c = \'Referral Accepted\'';
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Participant_Enrollment_Status_History__c> scope) {
        for (Participant_Enrollment_Status_History__c pe : scope) {
            pe.Status__c = PEStatusState.PE_STATUS_RECEIVED;
        }
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendPESHToEPR.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.UpdatePEHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.SendCalloutOnEligibilityPassedHandler.class);
        TriggerHandlerExecutor.bypassHandler(ParticipantEnrollmentSHTriggerHandler.CreateUsersOrSendNotificationsHandler.class);
        update scope;
    }

    global void finish(Database.BatchableContext bc) {

    }


}