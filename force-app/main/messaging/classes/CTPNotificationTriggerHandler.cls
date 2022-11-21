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
    private static void createNotificationCTPWasCreated(
        List<Clinical_Trial_Profile__c> newList,
        Map<Id, SObject> oldMap
    ) {
        List<Clinical_Trial_Profile__c> listForTrigger = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : newList) {
            if (ctp.Therapeutic_Area__c != null)
                listForTrigger.add(ctp);
        }
        List<Topic__c> topicList = NotificationService.getTopicListOrCreateNew(listForTrigger);
        Map<Id, Topic__c> topicByTopicIdMap = new Map<Id, Topic__c>();
        for (Topic__c t : topicList)
            topicByTopicIdMap.put(t.TopicId__c, t);

        List<Notification__c> notificationsForSubs = new List<Notification__c>();
        Topic__c topic = new Topic__c();
        for (Clinical_Trial_Profile__c ctp : listForTrigger) {
            topic = topicByTopicIdMap.get(ctp.Therapeutic_Area__c);
            /// Platform Level Notification
            if (topic != null) {
                notificationsForSubs.add(
                    new Notification__c(
                        Topic__c = topic.Id,
                        WhatId__c = ctp.Id,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_COI_CTP_START_ENROLL_TYPE
                    )
                );
            }
        }
        try {
            insert notificationsForSubs;
        } catch (DmlException e) {
        }
    }

    @TestVisible
    private static void createNotificationEnrollStarted(
        List<Clinical_Trial_Profile__c> newList,
        Map<Id, SObject> oldMap
    ) {
        List<String> enrollStatuses = new List<String>{
            TrialSearchWhereClauseFactory.ACTIVELY_ENROLLING,
            TrialSearchWhereClauseFactory.ENROLLING,
            TrialSearchWhereClauseFactory.OPEN_TO_ENROLLMENT
        };
        List<Clinical_Trial_Profile__c> ctpForNotifications = new List<Clinical_Trial_Profile__c>();
        for (Clinical_Trial_Profile__c ctp : newList) {
            String recruitmentStatus = ctp.Recruitment_Status__c;
            String overrideRecStatus = ctp.Override_Recruitment_Status__c;
            if (
                (enrollStatuses.contains(overrideRecStatus) ||
                (enrollStatuses.contains(recruitmentStatus))) &&
                (recruitmentStatus !=
                ((Clinical_Trial_Profile__c) oldMap.get(ctp.Id)).Recruitment_Status__c ||
                overrideRecStatus !=
                ((Clinical_Trial_Profile__c) oldMap.get(ctp.Id)).Override_Recruitment_Status__c)
            ) {
                ctpForNotifications.add(ctp);
            }
        }
        if (!ctpForNotifications.isEmpty()) {
            List<Topic__c> topicList = NotificationService.getTopicListOrCreateNewByCTPId(
                ctpForNotifications
            );
            Map<Id, Topic__c> topicByTopicIdMap = new Map<Id, Topic__c>();
            for (Topic__c t : topicList)
                topicByTopicIdMap.put(t.TopicId__c, t);

            List<Notification__c> notificationsForSubs = new List<Notification__c>();
            Topic__c topic = new Topic__c();
            ///PlatformLevel Notification
            for (Clinical_Trial_Profile__c ctp : ctpForNotifications) {
                topic = topicByTopicIdMap.get(ctp.Id);
               // pass neww class -- whatid as parameter 
                notificationsForSubs.add(
                    new Notification__c(
                        Topic__c = topic.Id,
                        WhatId__c = ctp.Id,
                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_COI_CTP_START_ENROLL_TYPE
                    )
                );
            }

            try {
                insert notificationsForSubs;
            } catch (DmlException e) {
            }
        }
    }

    @TestVisible
    private static void createNotificationCTPTrialCompleted(
        List<Clinical_Trial_Profile__c> newCTPs
    ) {
        List<Id> completedCTPIds = new List<Id>();
        for (Clinical_Trial_Profile__c ctp : newCTPs) {
            if (ctp.Status__c == ClinicalTrialProfileService.STATUS_COMPLETED)
                completedCTPIds.add(ctp.Id);
        }
		if(!completedCTPIds.isEmpty()){
			Database.executeBatch(new Batch_UpdatePETrialCompleteAndSendNotify(completedCTPIds), 10);
		}
    }
}
