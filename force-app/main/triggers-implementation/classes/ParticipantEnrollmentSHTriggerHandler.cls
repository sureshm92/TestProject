/**
 * Created by Kryvolap
 */

public without sharing class ParticipantEnrollmentSHTriggerHandler {

    //Handlers----------------------------------------------------------------------------------------------------------
    public class SendPESHToEPR extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            sendToEPR(newList);
        }
    }

    public class UpdatePEHandler extends TriggerHandler {

        public override void beforeInsert(List<SObject> newList) {
            updateEnrollmentStatus((List<Participant_Enrollment_Status_History__c>) newList);
        }
    }

    //Logic-------------------------------------------------------------------------------------------------------------
    private static void sendToEPR(List<Participant_Enrollment_Status_History__c> newList) {
        List<Id> ids = new List<Id>();
        for (Participant_Enrollment_Status_History__c obj : newList) {
            ids.add(obj.Id);
        }
        if (!System.isBatch() && !System.isFuture()) {
            IntegrationService.sendPESHToEPRAsync(ids);
        } else {
            IntegrationService.sendPESHToEPR(ids);
        }
    }

    @TestVisible
    private static void updateEnrollmentStatus(List<Participant_Enrollment_Status_History__c> histories) {
        Set<Id> peIds = new Set<Id>();
        Map<Id, List<Participant_Enrollment_Status_History__c>> peToHistories =
                new Map<Id, List<Participant_Enrollment_Status_History__c>>();

        for (Participant_Enrollment_Status_History__c history : histories) {
            if(history.Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI || history.Status__c == PEStatusState.PE_STATUS_RECEIVED) continue;

            Id peId = history.ParticipantEnrollment__c;
            peIds.add(peId);

            if (!peToHistories.containsKey(peId)) {
                peToHistories.put(peId, new List<Participant_Enrollment_Status_History__c>());
            }
            peToHistories.get(peId).add(history);
        }

        List<Participant_Enrollment__c> enrollments = [
                SELECT Id,
                        Enrolled_Date__c,
                        Informed_Consent__c,
                        Last_Status_Changed_Notes__c,
                        Non_Enrollment_Reason__c,
                        Participant_Status__c,
                        Participant_Status_Last_Changed_Date__c
                FROM Participant_Enrollment__c
                WHERE Id IN:peIds
        ];
        for (Participant_Enrollment__c pe : enrollments) {
            Participant_Enrollment_Status_History__c headHistory = peToHistories.get(pe.Id).get(0);
            for (Participant_Enrollment_Status_History__c history : peToHistories.get(pe.Id)) {
                Integer headStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(headHistory.Status__c);
                Integer currentStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(history.Status__c);

                if((headStatusValue == currentStatusValue && headHistory.Date__c < history.Date__c)
                        || headStatusValue != Math.max(headStatusValue, currentStatusValue)) {
                    headHistory = history;
                }
            }

            pe.Last_Status_Changed_Notes__c = headHistory.Notes__c;
            pe.Non_Enrollment_Reason__c = headHistory.Reason__c;
            pe.Participant_Status_Last_Changed_Date__c = headHistory.Date__c;
            pe.Participant_Status__c = headHistory.Status__c;
            if(headHistory.Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
                    || headHistory.Status__c == PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS) {
                pe.Informed_Consent__c = true;
                pe.Enrolled_Date__c = headHistory.Date__c.date();
            }
        }

        update enrollments;
    }
}