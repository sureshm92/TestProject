/**
 * Created by Olga Skrynnikova on 12/5/2019.
 */

public with sharing class CTPNotificationTriggerHandler {
    // Handlers: -------------------------------------------------------------------------------------------------------

    public class CreateNotificationHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) {
            createNotificationCTPWasCreated(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createNotificationEnrollStarted(newList, oldMap);
            createNotificationCTPTrialCompleted(newList);
        }
    }

    // Logic: ----------------------------------------------------------------------------------------------------------

    @TestVisible
    private static void createNotificationCTPWasCreated(List<Clinical_Trial_Profile__c> newList, Map<Id, SObject> oldMap) {
        List<Clinical_Trial_Profile__c> listForTrigger = new List<Clinical_Trial_Profile__c>();
        for(Clinical_Trial_Profile__c ctp: newList){
            if (ctp.Therapeutic_Area__c !=null) listForTrigger.add(ctp);
        }
        List<Topic__c> topicList = NotificationService.getTopicListOrCreateNew(listForTrigger);
        Map<Id, Topic__c> topicByTopicIdMap = new Map<Id, Topic__c>();
        for (Topic__c t: topicList) topicByTopicIdMap.put(t.TopicId__c, t);

        List<Notification__c> notificationsForSubs = new List<Notification__c>();
        Topic__c topic = new Topic__c();
        for (Clinical_Trial_Profile__c ctp: listForTrigger){
            topic = topicByTopicIdMap.get(ctp.Therapeutic_Area__c);
            if(topic != null) {
                notificationsForSubs.add(new Notification__c(
                        Topic__c = topic.Id,
                        WhatId__c = ctp.Id,
                        Notification_Type__c = NotificationService.MESSAGE_TO_PT_NEW_COI_CTP_TYPE
                ));
            }
        }
        try {
            insert notificationsForSubs;
        } catch (DmlException e) {
        }
    }

    @TestVisible
    private static void createNotificationEnrollStarted(List<Clinical_Trial_Profile__c> newList, Map<Id, SObject> oldMap) {
        List<String> enrollStatuses = new List<String>{
                TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING,
                TrialSearchWhereClauseFactory.ENROLLING,
                TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT
        };
        List<Clinical_Trial_Profile__c> ctpForNotifications = new List<Clinical_Trial_Profile__c>();
            for (Clinical_Trial_Profile__c ctp: newList){
                String recruitmentStatus = ctp.Recruitment_Status__c;
                String overrideRecStatus = ctp.Override_Recruitment_Status__c;
                        if ((enrollStatuses.contains(overrideRecStatus) || (enrollStatuses.contains(recruitmentStatus)))
                        && (recruitmentStatus != ((Clinical_Trial_Profile__c) oldMap.get(ctp.Id)).Recruitment_Status__c
                        || overrideRecStatus != ((Clinical_Trial_Profile__c) oldMap.get(ctp.Id)).Override_Recruitment_Status__c)){
                            ctpForNotifications.add(ctp);
                        }
            }
        if(!ctpForNotifications.isEmpty()){
            List<Topic__c> topicList = NotificationService.getTopicListOrCreateNewByCTPId(ctpForNotifications);
            Map<Id, Topic__c> topicByTopicIdMap = new Map<Id, Topic__c>();
            for (Topic__c t: topicList) topicByTopicIdMap.put(t.TopicId__c, t);

            List<Notification__c> notificationsForSubs = new List<Notification__c>();
            Topic__c topic = new Topic__c();
            for (Clinical_Trial_Profile__c ctp: ctpForNotifications){
                topic = topicByTopicIdMap.get(ctp.Id);
                notificationsForSubs.add(new Notification__c(
                        Topic__c = topic.Id,
                        WhatId__c = ctp.Id,
                        Notification_Type__c = NotificationService.MESSAGE_TO_PT_COI_CTP_START_ENROLL_TYPE
                ));
            }

            try {
                insert notificationsForSubs;
            } catch (DmlException e) {
            }
        }
    }

    @TestVisible
    private static void createNotificationCTPTrialCompleted(List<Clinical_Trial_Profile__c> newCTPs) {
        List<Id> completedCTPIds = new List<Id>();
        for(Clinical_Trial_Profile__c ctp : newCTPs) {
            if(ctp.Status__c == ClinicalTrialProfileService.STATUS_COMPLETED) completedCTPIds.add(ctp.Id);
        }

        List<Participant_Enrollment__c> participantContacts = [
                SELECT Id,
                        Participant__c,
                        Participant__r.Contact__c,
                        Clinical_Trial_Profile__c,
                        Participant_Status__c
                FROM Participant_Enrollment__c
                WHERE Clinical_Trial_Profile__c IN :completedCTPIds
                AND (Participant_Status__c NOT IN :PEStatusState.STATUSES_FAILED
                OR Participant_Status__c NOT IN :PEStatusState.PE_STATUS_GROUP_ALUMNI)
        ];

        Map<Id, List<Participant_Enrollment__c>> ctpIdsByPE = new Map<Id, List<Participant_Enrollment__c>>();

        List<Id> participantIds = new List<Id>();
        for(Participant_Enrollment__c pe : participantContacts) {
            participantIds.add(pe.Participant__c);
            if(ctpIdsByPE.containsKey(pe.Clinical_Trial_Profile__c)) ctpIdsByPE.get(pe.Clinical_Trial_Profile__c).add(pe);
            else ctpIdsByPE.put(pe.Clinical_Trial_Profile__c, new List<Participant_Enrollment__c>{pe});
            pe.Participant_Status__c = PEStatusState.PE_STATUS_TRIAL_COMPLETE;
        }
        update participantContacts;

        Map<Id, List<Id>> partPerDelegateIds = PatientDelegateService.getDelegatedContactIdsByParticipantIdMap(participantIds);

        Map<Id, List<Id>> ctpIdsByContactIds = new Map<Id, List<Id>>();
        for(Id ctp : ctpIdsByPE.keySet()) {
            if(!ctpIdsByContactIds.containsKey(ctp)) ctpIdsByContactIds.put(ctp, new List<Id>());
            for(Participant_Enrollment__c pe : ctpIdsByPE.get(ctp)) {
                ctpIdsByContactIds.get(ctp).add(pe.Participant__r.Contact__c);
                if(partPerDelegateIds.containsKey(pe.Participant__c)) {
                    ctpIdsByContactIds.get(ctp).addAll(partPerDelegateIds.get(pe.Participant__c));
                }
            }
        }

        NotificationService.sendSimpleNotification(ctpIdsByContactIds, NotificationService.MESSAGE_TO_PT_CTP_TRIAL_COMPLETE_TYPE);
    }
}