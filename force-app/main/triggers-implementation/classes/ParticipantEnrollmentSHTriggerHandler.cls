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
        IntegrationService.sendPESHToEPRAsync(ids);
    }

    @TestVisible
    private static void updateEnrollmentStatus(List<Participant_Enrollment_Status_History__c> histories) {
        Set<Id> peIds = new Set<Id>();
        Map<Id, List<Participant_Enrollment_Status_History__c>> peToHistories =
                new Map<Id, List<Participant_Enrollment_Status_History__c>>();

        for (Participant_Enrollment_Status_History__c history : histories) {
            if(history.NewStatus__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI) continue;

            Id peId = history.ParticipantEnrollment__c;
            peIds.add(peId);

            if (!peToHistories.containsKey(peId)) {
                peToHistories.put(peId, new List<Participant_Enrollment_Status_History__c>());
            }
            peToHistories.get(peId).add(history);
        }

        List<Participant_Enrollment__c> enrollments = [
                SELECT Id,
                        Informed_Consent__c,
                        Last_Status_Changed_Notes__c,
                        Non_Enrollment_Reason__c,
                        Participant_Status__c,
                        Participant_Status_Last_Changed_Date__c
                FROM Participant_Enrollment__c
                WHERE Id IN:peIds
        ];
        for (Participant_Enrollment__c pe : enrollments) {
            String largerStatus = pe.Participant_Status__c;
            Integer largerStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(largerStatus);
            for (Participant_Enrollment_Status_History__c history : peToHistories.get(pe.Id)) {
                Integer historyStatusValue = PEStatusState.PE_ORDERED_STATUSES.get(history.NewStatus__c);
                if (largerStatusValue != Math.max(largerStatusValue, historyStatusValue)) {
                    largerStatus = history.NewStatus__c;
                    largerStatusValue = historyStatusValue;

                    pe.Last_Status_Changed_Notes__c = history.Notes__c;
                    pe.Non_Enrollment_Reason__c = history.Reason__c;
                    pe.Participant_Status_Last_Changed_Date__c = history.Date__c;
                }
            }
            pe.Participant_Status__c = largerStatus;
            if(largerStatus == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS) pe.Informed_Consent__c = true;
        }

        update enrollments;
    }
}