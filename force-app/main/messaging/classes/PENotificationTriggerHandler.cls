/**
 * Created by Olga Skrynnikova on 11/22/2019.
 */

public without sharing class PENotificationTriggerHandler {

    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CreateNotificationHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createNotificationByStatus(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createNotificationByStatus(newList, oldMap);
        }
    }

    public class SendEmailIfSSWasChanged extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendEmailIfSSWasChanged((List<Participant_Enrollment__c>) newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void createNotificationByStatus(List<Participant_Enrollment__c> newList, Map<Id, SObject> oldMap) {
        List<Notification__c> notifications = new List<Notification__c>();
        List<Id> participantConIds = new List<Id>();
        List<Participant_Enrollment__c> listPE = [
                SELECT Id,
                        HCP_Contact_HCPEnroll__c,
                        Participant__c,
                        Participant__r.Contact__c,
                        Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                        Study_Site__r.Principal_Investigator__r.Id,
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
                //Forming additional notification for Enrollment Success
                if (pe.Participant_Status__c == PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS
                        && pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c) {
                    participantConIds.add(pe.Participant__r.Contact__c);
                    notifications.add(new Notification__c(
                            Recipient__c = pe.Participant__r.Contact__c,
                            WhatId__c = pe.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_ENROLLMENT_SUCCESS_TYPE
                    ));
                }
                //Forming additional notification for Drop Out
                if (pe.Participant_Status__c == PEStatusState.PE_STATUS_DROP_OUT) {
                    participantConIds.add(pe.Participant__r.Contact__c);
                    notifications.add(new Notification__c(
                            Recipient__c = pe.Participant__r.Contact__c,
                            WhatId__c = pe.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_DROP_OUT_TYPE
                    ));
                }
                //Forming additional notification for PI
                if (pe.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_SENT_TO_PI
                        || (pe.Participant_Status__c == PEStatusState.PE_STATUS_REFERRAL_ACCEPTED
                        && pe.IsAutoaccepted__c)) {
                    notifications.add(new Notification__c(
                            Recipient__c = pe.Study_Site__r.Principal_Investigator__r.Id,
                            WhatId__c = pe.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_NEW_PATIENT_REFERRAL_TYPE
                    ));
                }
            }

            if (notifyHCPType != null) {
                notifications.add(new Notification__c(
                        Recipient__c = pe.HCP_Contact_HCPEnroll__c,
                        WhatId__c = pe.Id,
                        Notification_Type__c = notifyHCPType
                ));
            }

            if (notifyPTType != null) {
                participantConIds.add(pe.Participant__r.Contact__c);
                notifications.add(new Notification__c(
                        Recipient__c = pe.Participant__r.Contact__c,
                        WhatId__c = pe.Id,
                        Notification_Type__c = notifyPTType
                ));
            }
        }

        //get Delegates for Participant
        List<Notification__c> listNotificationForDelegate = new List<Notification__c>();
        Map<Id, List<Contact>> conDelegatesByPartConMap = PatientDelegateService.getDelegatedCntsByParticipantCnt(
                participantConIds, new List<String>{'Id'}
        );
        for (Notification__c n : notifications) {
            if (conDelegatesByPartConMap.containsKey(n.Recipient__c)) {
                for (Contact conDel : conDelegatesByPartConMap.get(n.Recipient__c)) {
                    listNotificationForDelegate.add(new Notification__c(
                            Recipient__c = conDel.Id,
                            WhatId__c = n.WhatId__c,
                            Notification_Type__c = n.Notification_Type__c
                    ));
                }
            }
        }
        notifications.addAll(listNotificationForDelegate);

        insert notifications;
    }

    @TestVisible
    private static void sendEmailIfSSWasChanged(List<Participant_Enrollment__c> newList, Map<Id, Participant_Enrollment__c> oldMap) {
        List<Notification__c> notificationList = new List<Notification__c>();
        List<Id> peIds = new List<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (pe.Study_Site__c != oldMap.get(pe.Id).Study_Site__c) {
                peIds.add(pe.Id);
            }
        }
        for (Participant_Enrollment__c pe : [
                SELECT Id,
                        Study_Site__c,
                        Study_Site__r.Principal_Investigator__c,
                        Participant_Contact__c
                FROM Participant_Enrollment__c
                WHERE Id IN :peIds
        ]) {
            notificationList.add(new Notification__c(
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_SS_WAS_CHANGED_TYPE,
                    Recipient__c = pe.Participant_Contact__c,
                    WhatId__c = pe.Id));
            notificationList.add(new Notification__c(
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_SS_WAS_CHANGED_TYPE,
                    Recipient__c = pe.Study_Site__r.Principal_Investigator__c,
                    WhatId__c = pe.Id));
        }
        if (!notificationList.isEmpty()) insert notificationList;
    }
}