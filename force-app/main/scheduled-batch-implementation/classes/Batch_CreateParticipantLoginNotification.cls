/**
 * Created by Julia Kazakevich on 18-Sep-19.
 * Refactored by Igor Malyuta on 27-Oct-19
 */

public without sharing class Batch_CreateParticipantLoginNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT
                        Id,
                        Current_Participant_Enrollment__c,
                        Next_Notify_Date__c,
                        Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE Next_Notify_Date__c <= :Datetime.now().dateGmt()
                AND Current_Participant_Enrollment__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        createNearestLogOutNotification(contacts);
    }

    @TestVisible
    private static void createNearestLogOutNotification(List<Contact> contacts) {
        List<Id> participantContIds = new List<Id>();
        for (Contact cnt : contacts) participantContIds.add(cnt.Id);

        List<Participant_Enrollment__c> enrollments = [
                SELECT
                        Id,
                        Participant_Contact__c,
                        Participant__r.Contact__c,
                        Clinical_Trial_Profile__c,
                        Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c
                FROM Participant_Enrollment__c
                WHERE Participant_Contact__c IN :participantContIds
                AND Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL
                AND Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c != NULL
        ];

        Map<Id, Id> contactIdByCTPIds = new Map<Id, Id>();
        Map<Id, Integer> nearestNotificationByCTPIds = new Map<Id, Integer>();
        
        for (Participant_Enrollment__c pe : enrollments) {
            Id contactId = pe.Participant_Contact__c != null ? pe.Participant_Contact__c : pe.Participant__r.Contact__c;
            contactIdByCTPIds.put(contactId, pe.Clinical_Trial_Profile__c);
            Integer daysNotification = (Integer) pe.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c;

            Id ctpId = pe.Clinical_Trial_Profile__c;

            if (!nearestNotificationByCTPIds.containsKey(ctpId)) {
                nearestNotificationByCTPIds.put(
                        ctpId,
                        daysNotification
                );
            }

            Integer currentNotification = nearestNotificationByCTPIds.get(ctpId);
            if (currentNotification > daysNotification) {
                nearestNotificationByCTPIds.put(ctpId, daysNotification);
            }
        }

        List<Notification__c> notifications = new List<Notification__c>();
        List<Contact> updateContacts = new List<Contact>();
        for (Contact cnt : contacts) {
            if (contactIdByCTPIds.containsKey(cnt.Id) && nearestNotificationByCTPIds.containsKey(contactIdByCTPIds.get(cnt.Id))) {
                Integer nearestDay = nearestNotificationByCTPIds.get(contactIdByCTPIds.get(cnt.Id));
                cnt.Next_Notify_Date__c = Datetime.now().addDays(nearestDay).dateGmt();
                updateContacts.add(cnt);

                notifications.add(new Notification__c(
                        Recipient__c = cnt.Id,
                        WhatId__c = contactIdByCTPIds.get(cnt.Id),
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_HAS_NOT_LOGGED_IN_TYPE,
                        Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                ));
            }
        }

        update updateContacts;
        insert notifications;
    }

    public override Type getType() {
        return Batch_CreateParticipantLoginNotification.class;
    }

    public override String getBatchDescription() {
        return 'This job sends Emails and SMS when participant does not login in community X days';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }

}