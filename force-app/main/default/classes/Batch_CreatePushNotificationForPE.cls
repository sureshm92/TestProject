/**
 * Created by Alexey Moseev on 6/15/20.
 */

public without sharing class Batch_CreatePushNotificationForPE extends Batch_ScheduledAbstract {

    public static final Integer DAYS_NO_CONTACT = 5;

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT  Id,
                        Participant_Contact__c,
                        Participant__r.Contact__c,
                        PI_Contact__c,
                        Clinical_Trial_Profile__c
                FROM Participant_Enrollment__c
                WHERE Participant_Status__c = :PEStatusState.PE_STATUS_RECEIVED
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Participant_Enrollment__c> pes) {
        createPiPushNotifications(pes);
    }

    @TestVisible
    private static void createPiPushNotifications(List<Participant_Enrollment__c> pes) {
        Map<Id, Participant_Enrollment__c> pesByIds = new Map<Id, Participant_Enrollment__c>(pes);
        List<Participant_Enrollment_Status_History__c> pesHistories = [
                SELECT  ParticipantEnrollment__c,
                        ParticipantEnrollment__r.PI_Contact__c,
                        ParticipantEnrollment__r.Clinical_Trial_Profile__c,
                        Status__c,
                        CreatedDate,
                        Date__c
                FROM Participant_Enrollment_Status_History__c
                WHERE ParticipantEnrollment__c IN :pesByIds.keySet() AND
                      Status__c = :PEStatusState.PE_STATUS_RECEIVED AND
                      ParticipantEnrollment__r.PI_Contact__c != NULL
        ];

        List<Notification__c> notifications = new List<Notification__c>();
        for (Participant_Enrollment_Status_History__c peStatusHistory : pesHistories) {
            if (peStatusHistory.Date__c != null && peStatusHistory.Date__c.date().daysBetween(System.today()) >= DAYS_NO_CONTACT ||
                    peStatusHistory.CreatedDate.date().daysBetween(System.today()) >= DAYS_NO_CONTACT) {
                notifications.add(new Notification__c(
                        Recipient__c = peStatusHistory.ParticipantEnrollment__r.PI_Contact__c,
                        WhatId__c = peStatusHistory.ParticipantEnrollment__r.Clinical_Trial_Profile__c,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PI_CONTACT_PARTICIPANT_TYPE
                ));
            }
        }

        if (!notifications.isEmpty()) {
            insert notifications;
        }
    }

    public override Type getType() {
        return Batch_CreatePushNotificationForPE.class;
    }

    public override String getBatchDescription() {
        return 'This job creates Push notifications when PI doesn\'t contact Received Participants for X days';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }

}