/**
 * Created by Igor Malyuta on 14.05.2020.
 */
public with sharing class Batch_TrialMatchNotify extends Batch_ScheduledAbstract {

    private Map<Id, Set<Id>> enrollmentsByContact = new Map<Id, Set<Id>>();

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Participant_Enrollment__c,
                        Participant_Enrollment__r.Participant_Contact__c
                FROM Trial_Match__c
                WHERE Is_Eligible__c = TRUE
                AND Is_User_notified__c = FALSE
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Trial_Match__c> matches) {
        for (Trial_Match__c match : matches) {
            Participant_Enrollment__c enrollment = match.Participant_Enrollment__r;
            if (!enrollmentsByContact.containsKey(enrollment.Participant_Contact__c)) {
                enrollmentsByContact.put(enrollment.Participant_Contact__c, new Set<Id>());
            }
            enrollmentsByContact.get(enrollment.Participant_Contact__c).add(enrollment.Id);
            match.Is_User_notified__c = true;
        }

        update matches;
    }

    public override void finalAction() {
        Map<Id, List<Id>> delegatesContByParticipantContact =
                PatientDelegateService.getDelegateContactIdsByPAContactIs(new List<Id>(enrollmentsByContact.keySet()));

        List<Notification__c> notifications = new List<Notification__c>();
        for(Id partContactId : enrollmentsByContact.keySet()) {
            List<Id> delegates = delegatesContByParticipantContact.get(partContactId);
            for(Id peId : enrollmentsByContact.get(partContactId)) {
                notifications.add(new Notification__c(
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_TRIAL_MATCH,
                        Recipient__c = partContactId,
                        WhatId__c = peId
                ));

                if(delegates != null) {
                    for (Id delCont : delegates) {
                        notifications.add(new Notification__c(
                                IsDelegate__c = true,
                                Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_TRIAL_MATCH,
                                Recipient__c = delCont,
                                WhatId__c = peId
                        ));
                    }
                }
            }
        }

        if(!notifications.isEmpty()) insert notifications;
    }

    public override String getBatchDescription() {
        return 'Processes Trial Matches ans creates patient notifications.';
    }

    public override String getRecommendedIntervalMode() {
        return INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 3;
    }

    public override Type getType() {
        return Batch_TrialMatchNotify.class;
    }
}