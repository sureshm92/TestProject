/**
 * Created by Yulia Yakushenkova on 1/27/2020.
 */

public with sharing class Batch_UpdatePETrialCompleteAndSendNotify implements Database.Batchable<SObject>, Database.Stateful {
    private List<Participant_Enrollment__c> participantEnrollments;

    public Batch_UpdatePETrialCompleteAndSendNotify(List<Id> completedCTPIds) {
        participantEnrollments = [
            SELECT
                Id,
                Participant__c,
                Participant__r.Contact__c,
                Clinical_Trial_Profile__c,
                Participant_Status__c
            FROM Participant_Enrollment__c
            WHERE
                Clinical_Trial_Profile__c IN :completedCTPIds
                AND Participant_Status__c NOT IN :PEStatusState.PE_STATUS_GROUP_FAILED
                AND Participant_Status__c NOT IN :PEStatusState.PE_STATUS_GROUP_ALUMNI
        ];
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return participantEnrollments;
    }

    public void execute(Database.BatchableContext param1, List<SObject> participantEnrollments) {
        Map<Id, List<Participant_Enrollment__c>> ctpIdsByPE = new Map<Id, List<Participant_Enrollment__c>>();

        List<Id> participantIds = new List<Id>();
        for (
            Participant_Enrollment__c pe : (List<Participant_Enrollment__c>) participantEnrollments
        ) {
            participantIds.add(pe.Participant__c);
            if (ctpIdsByPE.containsKey(pe.Clinical_Trial_Profile__c))
                ctpIdsByPE.get(pe.Clinical_Trial_Profile__c).add(pe);
            else
                ctpIdsByPE.put(
                    pe.Clinical_Trial_Profile__c,
                    new List<Participant_Enrollment__c>{ pe }
                );
            pe.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        }
        update participantEnrollments;

        /*Map<Id, List<Id>> partPerDelegateIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(
            participantIds
        );*/
        String fieldFilter = 'Patient_Delegate__r.Participant__c';
        PatientDelegateEnrollmentService.PDEWrapper pdewrapper = PatientDelegateEnrollmentService.getDelegatedContactIdsByParticipantIdMap(
            participantIds,fieldFilter
        );
        Map<Id, List<Id>> partPerDelegateIds = pdewrapper.delParticipantIds; // Actual participant with list of delegate contact IDs

        List<Notification__c> notifications = new List<Notification__c>();
        ///Study Level Notification
        for (Id ctp : ctpIdsByPE.keySet()) {
            for (Participant_Enrollment__c pe : ctpIdsByPE.get(ctp)) {
                if (pe.Participant__r.Contact__c != null) {
                    notifications.add(
                        new Notification__c(
                            Recipient__c = pe.Participant__r.Contact__c,
                            WhatId__c = pe.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_CTP_TRIAL_COMPLETE_TYPE
                        )
                    );
                }
                if (partPerDelegateIds.containsKey(pe.Participant__c)) {
                    for (Id delegateId : partPerDelegateIds.get(pe.Participant__c)) {
                        notifications.add(
                            new Notification__c(
                                Recipient__c = delegateId,
                                IsDelegate__c = true,
                                WhatId__c = pe.Id,
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_CTP_TRIAL_COMPLETE_TYPE_DGT
                            )
                        );
                    }
                }
            }
        }
        insert notifications;
    }

    public void finish(Database.BatchableContext param1) {
    }
}
