/**
 * Created by Igor Malyuta on 14.05.2020.
 */
public with sharing class Batch_TrialMatchNotify extends Batch_ScheduledAbstract {

    private Map<Id, Map<String, Id>> enrollmentsByTemplateByContact = new Map<Id, Map<String, Id>>();

    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator([
                SELECT Participant_Enrollment__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__r.CommunityTemplate__c,
                        Participant_Enrollment__r.Participant_Contact__c
                FROM Trial_Match__c
                WHERE Is_Eligible__c = TRUE
                AND Is_User_notified__c = FALSE
        ]);
    }

    public void execute(Database.BatchableContext param1, List<Trial_Match__c> matches) {
        for (Trial_Match__c match : matches) {
            Participant_Enrollment__c enrollment = match.Participant_Enrollment__r;
            if (!enrollmentsByTemplateByContact.containsKey(enrollment.Participant_Contact__c)) {
                enrollmentsByTemplateByContact.put(enrollment.Participant_Contact__c, new Map<String, Id>());
            }

            Map<String, Id> enrollmentsByTemplate = enrollmentsByTemplateByContact.get(enrollment.Participant_Contact__c);
            String communityTemplate = enrollment.Clinical_Trial_Profile__r.CommunityTemplate__c;
            if(!enrollmentsByTemplate.containsKey(communityTemplate)) {
                enrollmentsByTemplate.put(communityTemplate, enrollment.Id);
            }

            match.Is_User_notified__c = true;
        }

        update matches;
    }

    public override void finalAction() {
        Map<Id, List<Id>> delegatesContByParticipantContact =
                PatientDelegateService.getDelegateContactIdsByPAContactIs(new List<Id>(enrollmentsByTemplateByContact.keySet()));

        List<Notification__c> notifications = new List<Notification__c>();
        for(Id partContactId : enrollmentsByTemplateByContact.keySet()) {
            List<Id> delegates = delegatesContByParticipantContact.get(partContactId);
            Map<String, Id> enrollmentsByTemplate = enrollmentsByTemplateByContact.get(partContactId);
            for (String template : enrollmentsByTemplate.keySet()) {
                Id peId = enrollmentsByTemplate.get(template);
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