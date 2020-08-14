/**
 * Created by D.Yasinskyi on 08.06.2018
 */
public without sharing class ShareModalController {

    @AuraEnabled
    public static void sendEmail(String whatId, String fromId, String email, String emailType) {
        try {
            if (fromId == null) fromId = CommunityService.getUserContact().Id;
			List<Contact> CntList = [Select Id from Contact where Email=:email limit 1];	
            Id sourceId = whatId;
            String type;
            if (sourceId.getSobjectType() == Participant_Enrollment__c.getSObjectType()) {
                if(!CntList.isEmpty())
                	{
                	fromId=CntList.get(0).Id;
                	type = NotificationCatalog.MESSAGE_TO_EXUS_SHARED_STUDY_BY_PE_TYPE;
                	}
                else type = NotificationCatalog.MESSAGE_TO_EXUS_SHARED_STUDY_BY_PE_TYPE_NO_CNT;
            } else if (sourceId.getSobjectType() == HCP_Enrollment__c.getSObjectType()) {
                if(!CntList.isEmpty())
                	{
                	fromId=CntList.get(0).Id;
                	type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_STUDY_BY_HCP_TYPE;
                	}    
                else type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_STUDY_BY_HCP_TYPE_NO_CNT;
            } else if (sourceId.getSobjectType() == Clinical_Trial_Profile__c.getSObjectType()) {
                if(!CntList.isEmpty())
                	{
                    fromId=CntList.get(0).Id;
                    type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_SOCIAL_STUDY_TYPE;
                	}
                else type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_SOCIAL_STUDY_TYPE_NO_CNT;
            } else if (sourceId.getSobjectType() == Resource__c.getSObjectType()) {
                if(!CntList.isEmpty())
                	{
                    fromId=CntList.get(0).Id;
                    type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_RESOURCES_TYPE;
                	}
                else type = NotificationCatalog.MESSAGE_TO_EXUS_SHARE_RESOURCES_TYPE_NO_CNT;

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