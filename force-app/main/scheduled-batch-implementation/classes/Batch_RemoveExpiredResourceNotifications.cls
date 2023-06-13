public with sharing class Batch_RemoveExpiredResourceNotifications extends Batch_ScheduledAbstract {
    public List<String> stdResUpdateNotificationType = new List<String>();
    public List<String> platformResUpdateNotificationType = new List<String>();
    public Database.QueryLocator start(Database.BatchableContext param1) {
        stdResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_ARTICLE_TYPE);
        stdResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_DOC_TYPE);
        stdResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_LINK_TYPE);
        stdResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_MULTIMEDIA_TYPE);
        stdResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_VIDEO_TYPE);
        platformResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_PLATFROM_ARTICLE_TYPE);
        platformResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_PLATFROM_DOCUMENT_TYPE);
        platformResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_LINK_TYPE);
        platformResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_PLATFROMMULTIMEDIA_TYPE);
        platformResUpdateNotificationType.add(NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE);
        return Database.getQueryLocator(
            [
                SELECT Id,
                Target_Type__c,
                Status__c,
                Notification__r.Notification_Type__c,
                Notification__r.Target_Record_Ids__c,
                Notification__r.WhatId__c,
                Notification__r.Status__c 
                FROM Send_Result__c 
                WHERE Target_Type__c='Updates'
                AND Status__c =:UpdateService.SR_STATUS_IN_PROGRESS 
                AND Notification__r.Status__c =:UpdateService.SR_STATUS_IN_PROGRESS
                AND (Notification__r.Notification_Type__c IN :stdResUpdateNotificationType
                     OR Notification__r.Notification_Type__c IN:platformResUpdateNotificationType)
                AND Notification__r.WhatId__c != Null
                AND Notification__r.Target_Record_Ids__c != Null
            ]
        );
    }
    public void execute(Database.BatchableContext param1, List<Send_Result__c> sendResults) {
        Set<Id> peIds = new Set<Id>();
        Set<Id> stdResIds = new Set<Id>();
        Set<Id> platformResIds = new Set<Id>();
        List<Id> notificationIds = new List<Id>();
        List<Send_Result__c> sendResultToUpdate = new List<Send_Result__c>();
        for(Send_Result__c sr : sendResults){
            if(stdResUpdateNotificationType.contains(sr.Notification__r.Notification_Type__c)){
                peIds.add(sr.Notification__r.WhatId__c);
                stdResIds.add(sr.Notification__r.Target_Record_Ids__c);
            }else if(platformResUpdateNotificationType.contains(sr.Notification__r.Notification_Type__c)){
                platformResIds.add(sr.Notification__r.Target_Record_Ids__c);
            }
        }
        Map<Id,Participant_Enrollment__c> peMap = new Map<Id,Participant_Enrollment__c>([SELECT Id,Participant_Status__c FROM Participant_Enrollment__c WHERE Id IN:peIds]);
        Map<Id,Res_study__c> stdResMap = new Map<Id,Res_study__c>([SELECT Id,Expires_On_Status__c,resource__r.Expiration_Date__c FROM Res_study__c WHERE Id IN:stdResIds AND (Expires_On_Status__c!=Null OR resource__r.Expiration_Date__c <=:Date.today())]);
        Map<Id,Resource__c> platformResMap = new Map<Id,Resource__c>([SELECT Id,Expiration_Date__c FROM Resource__c WHERE Id IN:platformResIds AND Expiration_Date__c<=: Date.today()]);
        for(Send_Result__c sr : sendResults){
            if(stdResMap.containsKey(sr.Notification__r.Target_Record_Ids__c) && peMap.containsKey(sr.Notification__r.WhatId__c)){
                if((String.isNotBlank(stdResMap.get(sr.Notification__r.Target_Record_Ids__c).Expires_On_Status__c) 
                    && (PEStatusState.PE_ORDERED_STATUSES.get(stdResMap.get(sr.Notification__r.Target_Record_Ids__c).Expires_On_Status__c) 
                        <= PEStatusState.PE_ORDERED_STATUSES.get(peMap.get(sr.Notification__r.WhatId__c).Participant_Status__c)))
                   ||(stdResMap.get(sr.Notification__r.Target_Record_Ids__c).resource__r.Expiration_Date__c!=Null)
                  ){
                      sr.Status__c = 'Sent';
                      sendResultToUpdate.add(sr);
                      notificationIds.add(sr.Notification__c);
                  }
            }else if(platformResMap.containsKey(sr.Notification__r.Target_Record_Ids__c)){
                sr.Status__c = 'Sent';
                sendResultToUpdate.add(sr);
                notificationIds.add(sr.Notification__c);
            }
        }
        if (!sendResultToUpdate.isEmpty()) {
            update sendResultToUpdate;
        }
        if (!notificationIds.isEmpty()) {
            UpdateService.getInstance().updateNotificationsStatus(notificationIds);
        }
    }
    public override Type getType() {
        return Batch_RemoveExpiredResourceNotifications.class;
    }
    
    public override String getBatchDescription() {
        return 'This job removes expired update notifications for recources';
    }
    
    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_DAYS;
    }
    
    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}