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
                WHERE Next_Notify_Date__c <=: Datetime.now().dateGmt()
                AND Current_Participant_Enrollment__c != NULL
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Contact> contacts) {
        List<Id> cntIds = new List<Id>();
        for (Contact cnt : contacts) cntIds.add(cnt.Id);
        Map<Id, Integer> conIdsAndNearestNotifyDate = ParticipantService.getNearestLogOutNotification(cntIds);
        List<Notification__c> notifications = new List<Notification__c>();
        List<Contact> listOfContactEmails = new List<Contact>();
        List<Participant__c> participants = [SELECT Id, Contact__c FROM Participant__c WHERE Contact__c IN: cntIds];
        Map<Id, Participant__c> participantByContactIdMap = new Map<Id, Participant__c>();
        for(Participant__c p : participants) if (p.Contact__c != null) participantByContactIdMap.put(p.Contact__c, p);
        for(Contact cnt : contacts) {
            if(conIdsAndNearestNotifyDate.containsKey(cnt.Id)) {
                cnt.Next_Notify_Date__c = Datetime.now().addDays(conIdsAndNearestNotifyDate.get(cnt.Id)).dateGmt();
                listOfContactEmails.add(cnt);
                Participant__c p = participantByContactIdMap.get(cnt.Id);
                if(p != null){
                    notifications.add(new Notification__c(
                            Recipient__c = cnt.Id,
                            WhatId__c = p.Id,
                            Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_HAS_NOT_LOGGED_IN_TYPE,
                            Status__c = NotificationService.NOTIFICATION_STATUS_PENDING
                    ));
                }
            }
        }

        if (!listOfContactEmails.isEmpty()) {
            update listOfContactEmails;
            insert notifications;
        }
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