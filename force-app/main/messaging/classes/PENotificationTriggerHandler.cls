/**
 * Created by Olga Skrynnikova on 11/22/2019.
 */

public without sharing class PENotificationTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CreateNotificationHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createNotificationByStatus(newList, null);
            referredToNewStudyDelegateNotifications(newList);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createNotificationByStatus(newList, (Map<Id, Participant_Enrollment__c>) oldMap);
        }
    }

    public class SendEmailIfSSWasChanged extends TriggerHandler {
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendEmailIfSSWasChanged(
                (List<Participant_Enrollment__c>) newList,
                (Map<Id, Participant_Enrollment__c>) oldMap
            );
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void createNotificationByStatus(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<String> peStatusesSuccess = new List<String>{
            PEStatusState.PE_STATUS_ENROLLMENT_SUCCESS,
            PEStatusState.PE_STATUS_RANDOMIZATION_SUCCESS
        };
        List<String> skipNotifyTypesDel = new List<String>{
            NotificationCatalog.MESSAGE_TO_PT_DROP_OUT_TYPE,
            NotificationCatalog.MESSAGE_TO_PT_ENROLLMENT_SUCCESS_TYPE
        };
        List<Notification__c> notifications = new List<Notification__c>();
        List<Id> participantConIds = new List<Id>();
        List<Participant_Enrollment__c> PEs = [
            SELECT
                Id,
                HCP_Contact_HCPEnroll__c,
                Participant__c,
                Participant__r.Contact__c,
                Participant__r.Contact__r.Visited_Communities__c,
                Clinical_Trial_Profile__r.Patient_Portal_Enabled__c,
                Clinical_Trial_Profile__r.CommunityTemplate__c,
                Study_Site__r.Principal_Investigator__r.Id,
                Participant_Status__c,
                Is_Virtual_Study_Site__c,
                Referral_Source__c,
                IsAutoaccepted__c,
                Source_Type__c
            FROM Participant_Enrollment__c
            WHERE Id IN :newList AND Participant__r.Contact__c != NULL
        ];

        for (Participant_Enrollment__c pe : PEs) {
            String notifyHCPType, notifyPTType;

            //Forming list notifications for HCPs and Patients
            Boolean notContainsForPT = false, notContainsForHCP = false;
            if (
                oldMap != null &&
                pe.Participant_Status__c != (oldMap.get(pe.Id)).Participant_Status__c
            ) {
                notContainsForHCP = !NotificationService.participantStatusListForHCP.contains(
                    pe.Participant_Status__c
                );
                notContainsForPT = !NotificationService.participantStatusListForPT.contains(
                    pe.Participant_Status__c
                );
            }
            if (pe.HCP_Contact_HCPEnroll__c != null)
                notifyHCPType = NotificationService.checkHCPNotificationType(pe, notContainsForHCP);
            notifyPTType = pe.Is_Virtual_Study_Site__c
                ? NotificationService.checkPatientNotificationVTType(pe)
                : NotificationService.checkPatientNotificationType(pe, notContainsForPT);

            String recipient;
            if (notifyHCPType != null) {
                recipient = pe.HCP_Contact_HCPEnroll__c;
                notifications.add(
                    new Notification__c(
                        Recipient__c = recipient,
                        WhatId__c = pe.Id,
                        Notification_Type__c = notifyHCPType
                    )
                );
            }
            if (notifyPTType != null) {
                recipient = pe.Participant__r.Contact__c;
                notifications.add(
                    new Notification__c(
                        Recipient__c = recipient,
                        WhatId__c = pe.Id,
                        Notification_Type__c = notifyPTType
                    )
                );
                participantConIds.add(pe.Participant__r.Contact__c);
            }

            if (
                oldMap == null ||
                (oldMap != null &&
                pe.Participant_Status__c != (oldMap.get(pe.Id)).Participant_Status__c)
            ) {
                String notificationTypePT;
                //Forming additional notification for Enrollment Success
                if (
                    peStatusesSuccess.contains(pe.Participant_Status__c) &&
                    pe.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
                ) {
                    String visitedCommunities = pe.Participant__r.Contact__r.Visited_Communities__c;
                    String currentCommunityName = CommunityTemplateService.getTemplate(
                            pe.Clinical_Trial_Profile__r.CommunityTemplate__c
                        )
                        .templateName;
                    Boolean checkVisitedCommunity = false;
                    if (currentCommunityName != null && visitedCommunities != null)
                        checkVisitedCommunity = visitedCommunities.contains(currentCommunityName);
                    if (checkVisitedCommunity) {
                        participantConIds.add(pe.Participant__r.Contact__c);
                        notificationTypePT = NotificationCatalog.MESSAGE_TO_PT_ENROLLMENT_SUCCESS_TYPE; // study Level
                    }
                }

                //Forming additional notification for Drop Out
                if (pe.Participant_Status__c == PEStatusState.PE_STATUS_DROP_OUT) {
                    notificationTypePT = NotificationCatalog.MESSAGE_TO_PT_DROP_OUT_TYPE; // study Level
                }
                if (notificationTypePT != null) {
                    notifications.add(
                        new Notification__c(
                            Recipient__c = pe.Participant__r.Contact__c,
                            WhatId__c = pe.Id,
                            Notification_Type__c = notificationTypePT,
                            Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                        )
                    );
                }
            }
        }

        //get Delegates for Participant
        List<Notification__c> delegateNotifications = new List<Notification__c>();
        Map<Id, List<Contact>> delegateContactsByPartCnt = PatientDelegateEnrollmentService.getDelegatedCntsByParticipantCnt(
            participantConIds,
            new List<String>{ 'Id' }
        );
        // !skipNotifyTypesDel -- all are hcp or virual study Notifications .
        for (Notification__c n : notifications) { //
            if (
                !skipNotifyTypesDel.contains(n.Notification_Type__c) &&
                delegateContactsByPartCnt.containsKey(n.Recipient__c)
            ) {
                for (Contact contact : delegateContactsByPartCnt.get(n.Recipient__c)) {
                    delegateNotifications.add(
                        new Notification__c(
                            Recipient__c = contact.Id,
                            WhatId__c = n.WhatId__c,
                            Notification_Type__c = n.Notification_Type__c,
                            IsDelegate__c = true
                        )
                    );
                }
            }
        }
        notifications.addAll(delegateNotifications);

        insert notifications;
    }

    @TestVisible
    private static void referredToNewStudyDelegateNotifications(
        List<Participant_Enrollment__c> newList
    ) {
        List<Id> participantConIds = new List<Id>();
        List<Id> perIdList = new List<Id>();
        List<Notification__c> notifications = new List<Notification__c>();
        Map<String, Map<Id, List<Participant_Enrollment__c>>> pesByCommunityName = new Map<String, Map<Id, List<Participant_Enrollment__c>>>();

        for (Participant_Enrollment__c pe : newList) {
            if (pe.Participant_Contact__c != null)
                participantConIds.add(pe.Participant_Contact__c);
                perIdList.add(pe.Id);
        }

        List<Participant_Enrollment__c> allPEs = [
            SELECT Id, Clinical_Trial_Profile__r.CommunityTemplate__c, Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE Participant_Contact__c IN :participantConIds
        ];

        for (Participant_Enrollment__c pe : allPEs) {
            if (
                !pesByCommunityName.keySet()
                    .contains(pe.Clinical_Trial_Profile__r.CommunityTemplate__c)
            ) {
                pesByCommunityName.put(
                    pe.Clinical_Trial_Profile__r.CommunityTemplate__c,
                    new Map<Id, List<Participant_Enrollment__c>>()
                );
            }
            Map<Id, List<Participant_Enrollment__c>> pesByPartCont = pesByCommunityName.get(
                pe.Clinical_Trial_Profile__r.CommunityTemplate__c
            );
            if (!pesByPartCont.keySet().contains(pe.Participant_Contact__c)) {
                pesByPartCont.put(pe.Participant_Contact__c, new List<Participant_Enrollment__c>());
            }
            pesByPartCont.get(pe.Participant_Contact__c).add(pe);
        }

        Map<Id, List<Contact>> delegateContactsByPartCnt = PatientDelegateEnrollmentService.getDelegatedCntsByParticipantCnt(
            participantConIds,
            new List<String>{ 'Id' },
            perIdList
        );

        Boolean isFutureContext = System.isFuture() || System.isBatch();
        for (Participant_Enrollment__c pe : newList) {
            String communityName;
            if (!isFutureContext) {
                communityName = ((Clinical_Trial_Profile__c) PETriggerBuffer.getSObject(
                        pe.Clinical_Trial_Profile__c
                    ))
                    .CommunityTemplate__c;
            } else if (pe.Clinical_Trial_Profile__r != null) {
                communityName = pe.Clinical_Trial_Profile__r.CommunityTemplate__c;
            }
            if (pesByCommunityName.get(communityName) != null) {
                Map<Id, List<Participant_Enrollment__c>> pesByPartCont = pesByCommunityName.get(
                    communityName
                );
                if (
                    pesByPartCont.get(pe.Participant_Contact__c).size() > 1 &&
                    delegateContactsByPartCnt.keySet().contains(pe.Participant_Contact__c)
                ) {
                    for (
                        Contact delegate : delegateContactsByPartCnt.get(pe.Participant_Contact__c)
                    ) {
                        notifications.add(
                            new Notification__c(
                                Recipient__c = delegate.Id,
                                WhatId__c = pe.Id,
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_DEL_NEW_STUDY_TYPE,// when existing delegate added to new study
                                IsDelegate__c = true
                            )
                        );
                    }
                }
            }
        }
        insert notifications;
    }

    @TestVisible
    private static void sendEmailIfSSWasChanged(
        List<Participant_Enrollment__c> newList,
        Map<Id, Participant_Enrollment__c> oldMap
    ) {
        List<Notification__c> notificationList = new List<Notification__c>();
        List<Id> peIds = new List<Id>();
        for (Participant_Enrollment__c pe : newList) {
            if (
                pe.Study_Site__c != oldMap.get(pe.Id).Study_Site__c &&
                oldMap.get(pe.Id).Study_Site__c != null &&
                !(oldMap.get(pe.Id).Participant_Status__c == 'Pending Referral' &&
                (pe.Participant_Status__c == 'Received' ||
                pe.Participant_Status__c == 'Eligibility Passed'))
            ) {
                peIds.add(pe.Id);
            }
        }
        if(!peIds.isEmpty()){
        for (Participant_Enrollment__c pe : [
            SELECT
                Id,
                Study_Site__c,
                Study_Site__r.Principal_Investigator__c,
                Participant_Contact__c
            FROM Participant_Enrollment__c
            WHERE Id IN :peIds
        ]) {
            if (pe.Participant_Contact__c != null) {
                notificationList.add(
                    new Notification__c(
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_SS_WAS_CHANGED_TYPE,
                        Recipient__c = pe.Participant_Contact__c,
                        WhatId__c = pe.Id
                    )
                );
            }
            if (pe.Study_Site__r.Principal_Investigator__c != null) {
                notificationList.add(
                    new Notification__c(
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_SS_WAS_CHANGED_TYPE,
                        Recipient__c = pe.Study_Site__r.Principal_Investigator__c,
                        WhatId__c = pe.Id
                    )
                );
                for (Site_Staff__c delegate : [
                    SELECT Id, Site_Contact__c
                    FROM Site_Staff__c
                    WHERE
                        Delegate_Level__c = :DelegateService.DELEGATE_LEVEL_1
                        AND Study_Site__c = :pe.Study_Site__c
                ]) {
                    notificationList.add(
                        new Notification__c(
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_SS_WAS_CHANGED_TYPE,
                            Recipient__c = delegate.Site_Contact__c,
                            WhatId__c = pe.Id
                        )
                    );
                }
            }
        }
        }
        if (!notificationList.isEmpty())
            insert notificationList;
    }
}