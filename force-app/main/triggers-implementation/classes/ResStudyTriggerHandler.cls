/**
 * Created by Yehor Dobrovolskyi
 */
public with sharing class ResStudyTriggerHandler {
    public class PlatformEventProcessor extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(
                PlatformEventService.class
            );
            platformEventService.remindEventFire((List<Res_study__c>) newList);
        }

        public override void afterDelete(List<SObject> oldList) {
            PlatformEventService platformEventService = (PlatformEventService) ClassFactory.newInstance(
                PlatformEventService.class
            );
            platformEventService.remindEventFire((List<Res_study__c>) oldList);
        }
    }
    public class CertificateResourceProcessor extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            notifyParticipantAndDelegateAboutCertificate(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    private static void notifyParticipantAndDelegateAboutCertificate(List<SObject> newList) {
        List<Id> resStudyIds = new List<Id>();
        for (SObject obj : newList)
            resStudyIds.add(obj.Id);

        List<Res_study__c> resStudies = new List<Res_study__c>();
        for (SObject resStudy : [
            SELECT Id, Clinical_Trial_Profile__c, Visible_To_Delegates__c, Visible_To_Participant__c
            FROM Res_study__c
            WHERE
                Resource__r.document_type__c = 'Certificate'
                AND Id IN :resStudyIds
                AND Visible_To_Participant__c = TRUE
                AND Notify_On_Availability__c = TRUE
                AND Clinical_Trial_Profile__r.Study_Documents_Are_Available__c = TRUE
        ]) {
            resStudies.add((Res_study__c) resStudy);
        }

        Map<Id, List<Res_study__c>> resByCTPIds = new Map<Id, List<Res_study__c>>();

        for (Res_study__c resStudy : resStudies) {
            Id ctpId = resStudy.Clinical_Trial_Profile__c;
            if (resByCTPIds.containsKey(ctpId))
                resByCTPIds.get(ctpId).add(resStudy);
            else
                resByCTPIds.put(ctpId, new List<Res_study__c>{ resStudy });
        }

        Map<Id, List<Res_study__c>> participantByResources = new Map<Id, List<Res_study__c>>();
        List<Participant_Enrollment__c> pes = [
            SELECT Id, Participant__r.Contact__c, Clinical_Trial_Profile__c, Participant__c
            FROM Participant_Enrollment__c
            WHERE Clinical_Trial_Profile__c IN :resByCTPIds.keySet()
        ];
        List<Id> participantIds = new List<Id>();
        for (Participant_Enrollment__c pe : pes) {
            participantByResources.put(
                pe.Participant__r.Contact__c,
                resByCTPIds.get(pe.Clinical_Trial_Profile__c)
            );
            participantIds.add(pe.Participant__c);
        }

        String fieldFilter = 'Patient_Delegate__r.Participant__c';
        PatientDelegateEnrollmentService.PDEWrapper pdewrapper = PatientDelegateEnrollmentService.getDelegatedContactIdsByParticipantIdMap(
            participantIds,fieldFilter
        );
        Map<Id, List<Id>> partPerDelegateIds = pdewrapper.delParticipantIds; // Actual participant with list of delegate contact IDs

       /* Map<Id, List<Id>> partPerDelegateIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(
            participantIds
        );*/

        List<Notification__c> notifications = new List<Notification__c>();
        for (Participant_Enrollment__c pe : pes)
            for (Res_study__c res : participantByResources.get(pe.Participant__r.Contact__c)) {
                if (pe.Participant__r.Contact__c != null) {
                    notifications.add(
                        new Notification__c(
                            Recipient__c = pe.Participant__r.Contact__c,
                            WhatId__c = pe.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_STDDOC_CERTIFICATE_TYPE,
                            Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                        )
                    );
                }
                if (
                    !partPerDelegateIds.keySet().isEmpty() &
                    partPerDelegateIds.containsKey(pe.Participant__c) && res.Visible_To_Delegates__c
                ) {
                    for (Id delegateId : partPerDelegateIds.get(pe.Participant__c))
                        notifications.add(
                            new Notification__c(
                                Recipient__c = delegateId,
                                WhatId__c = pe.Id,
                                IsDelegate__c = true;
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_STDDOC_CERTIFICATE_TYPE,
                                Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                            )
                        );
                }
            }
        insert notifications;
    }
}
