/**
 * Created by Julia Kazakevich on 18-Sep-19.
 * Refactored by Igor Malyuta on 27-Oct-19
 */
 
public without sharing class Batch_CreateParticipantLoginNotification extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Current_Participant_Enrollment__c,
                    Next_Notify_Date__c,
                    Participant_Opt_In_Status_Emails__c
                FROM Contact
                WHERE
                    Next_Notify_Date__c <= :Datetime.now().dateGmt()
                    AND Current_Participant_Enrollment__c != NULL
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        createNearestLogOutNotification(contacts);
    }

    @TestVisible
    private static void createNearestLogOutNotification(List<Contact> contacts) {
        List<Participant_Enrollment__c> enrollments = [
            SELECT
                Id,
                Participant_Contact__c,
                Clinical_Trial_Profile__c,
                Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c
            FROM Participant_Enrollment__c
            WHERE
                Participant_Contact__c IN :contacts
                AND Participant_Status__c IN :PEStatusState.PE_STATUS_GROUP_IN_PROGRESS_ALL
                AND Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c != NULL
        ];

        Map<Id, Map<Id, Integer>> ctpWithLoggedByCnt = new Map<Id, Map<Id, Integer>>();
        Map<String, Id> ctpIdContactIdVsPERMap = new Map<String, Id>();
        for (Participant_Enrollment__c enrollment : enrollments) {
            Id contactId = enrollment.Participant_Contact__c;
            if (!ctpWithLoggedByCnt.containsKey(contactId))
                ctpWithLoggedByCnt.put(contactId, new Map<Id, Integer>());

            Integer daysNotification = (Integer) enrollment.Clinical_Trial_Profile__r.Logged_Out_Days_Notification__c;
            ctpWithLoggedByCnt.get(contactId)
                .put(enrollment.Clinical_Trial_Profile__c, daysNotification);
            String ctpIdContactIdKey =
                enrollment.Clinical_Trial_Profile__c +
                '_' +
                enrollment.Participant_Contact__c;
            ctpIdContactIdVsPERMap.put(ctpIdContactIdKey, enrollment.Id);
        }

        List<Contact> updateContacts = new List<Contact>();
        List<Notification__c> notifications = new List<Notification__c>();
        for (Id contactId : ctpWithLoggedByCnt.keySet()) {
            Map<Id, Integer> daysByCtp = ctpWithLoggedByCnt.get(contactId);
            Id nearestCtp = (Id) daysByCtp.keySet().iterator().next();
            Integer nearestDay = daysByCtp.get(nearestCtp);
            String ctpIdContactIdKey = nearestCtp + '_' + contactId;
            for (Id ctpId : daysByCtp.keySet()) {
                if (daysByCtp.get(ctpId) < nearestDay) {
                    nearestCtp = ctpId;
                    nearestDay = daysByCtp.get(ctpId);
                    ctpIdContactIdKey = ctpId + '_' + contactId;
                }
            }

            updateContacts.add(
                new Contact(
                    Id = contactId,
                    Next_Notify_Date__c = Datetime.now().addDays(nearestDay).dateGmt()
                )
            );
            notifications.add(
                new Notification__c(
                    Recipient__c = contactId,
                    WhatId__c = ctpIdContactIdVsPERMap.get(ctpIdContactIdKey),
                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_HAS_NOT_LOGGED_IN_TYPE
                )
            );
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
