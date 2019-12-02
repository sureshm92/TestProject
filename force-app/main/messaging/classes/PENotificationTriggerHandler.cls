/**
 * Created by Olga Skrynnikova on 11/22/2019.
 */

public with sharing class PENotificationTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CreateNotificationHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createNotificationByStatus(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createNotificationByStatus(newList, oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void createNotificationByStatus(List<Participant_Enrollment__c> newList, Map<Id, SObject> oldMap) {
        List<Notification__c> listNotificationForHCP = new List<Notification__c>();
        List<Notification__c> listNotificationForPatient = new List<Notification__c>();
        List<Participant_Enrollment__c> listPE = [
                SELECT Id,
                        HCP_Contact_HCPEnroll__c,
                        Participant__r.Contact__c,
                        Participant_Status__c,
                        Is_Virtual_Study_Site__c,
                        Referral_Source__c,
                        IsAutoaccepted__c
                FROM Participant_Enrollment__c
                WHERE Id IN :newList
        ];

        for (Participant_Enrollment__c pe : listPE) {
            String notifyHCPType;
            String notifyPTType;

            //Forming list notifications for HCPs and Patients
            if (oldMap == null) {
                if (pe.HCP_Contact_HCPEnroll__c != null) notifyHCPType = NotificationService.checkHCPNotificationType(pe, false);
                notifyPTType =
                        pe.Is_Virtual_Study_Site__c ? NotificationService.checkPatientNotificationVTType(pe)
                                : NotificationService.checkPatientNotificationType(pe, false);
            } else if (pe.Participant_Status__c != ((Participant_Enrollment__c) oldMap.get(pe.Id)).Participant_Status__c) {
                if (pe.HCP_Contact_HCPEnroll__c != null) notifyHCPType = NotificationService.checkHCPNotificationType(pe,
                        !NotificationService.participantStatusListForHCP.contains(pe.Participant_Status__c));
                notifyPTType =
                        pe.Is_Virtual_Study_Site__c ? NotificationService.checkPatientNotificationVTType(pe)
                                : NotificationService.checkPatientNotificationType(pe, !NotificationService.participantStatusListForPT.contains(pe.Participant_Status__c));
            }

            if (notifyHCPType != null) {
                listNotificationForHCP.add(new Notification__c(
                        Recipient__c = pe.HCP_Contact_HCPEnroll__c,
                        WhatId__c = pe.Id,
                        Notification_Type__c = notifyHCPType,
                        Email_Status__c = NotificationService.EMAIL_STATUS_PENDING));
            }

            if (notifyPTType != null) {
                listNotificationForPatient.add(new Notification__c(
                        Recipient__c = pe.Participant__r.Contact__c,
                        WhatId__c = pe.Id,
                        Notification_Type__c = notifyPTType,
                        Email_Status__c = NotificationService.EMAIL_STATUS_PENDING));
            }
        }

        if (listNotificationForHCP != null) insert listNotificationForHCP;
        if (listNotificationForPatient != null) insert listNotificationForPatient;
    }
}