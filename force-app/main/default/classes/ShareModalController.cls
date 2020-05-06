/**
 * Created by D.Yasinskyi on 08.06.2018
 */
public without sharing class ShareModalController {

    @AuraEnabled
    public static void sendEmail(String whatId, String fromId, String email, String emailType) {
        try {
            if (fromId == null) fromId = CommunityService.getUserContact().Id;

            Id sourceId = whatId;
            String type;
            if (sourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                type = NotificationCatalog.MESSAGE_TO_EXUS_SHARED_STUDY_BY_PE_TYPE;
            } else if (sourceId.getSobjectType() == HCP_Enrollment__c.getSObjectType()) {
                type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_STUDY_BY_HCP_TYPE;
            } else if (sourceId.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
                type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_SOCIAL_STUDY_TYPE;
            } else if (sourceId.getSobjectType() == Resource__c.getSObjectType()) {
                type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_RESOURCES_TYPE;
            }

            insert new Notification__c(
                    WhatId__c = whatId,
                    Email__c = email,
                    From__c = fromId,
                    Notification_Type__c = type
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
}