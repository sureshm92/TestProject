public without sharing class PPUpdatesController {
    @AuraEnabled
    public static List<UpdateService.UpdateWrapper> getSendResultUpdates(
        Integer offsets,
        Integer limits,
        String initialLoadTime
    ) {
        List<UpdateService.UpdateWrapper> updateWrapperlist = new List<UpdateService.UpdateWrapper>();
        List<Id> resStudyIds = new List<Id>();
        List<Id> resPlatformIds = new List<Id>();
        List<Id> patientVisitIds = new List<Id>();
        UpdateService instanceObj = UpdateService.getInstance();
        List<Send_Result__c> sendResults = instanceObj.getSendResultRecords(
            resStudyIds,
            resPlatformIds,
            patientVisitIds,
            offsets,
            limits,
            initialLoadTime
        );
        Map<Id, Res_study__c> resStudyMap = instanceObj.getResStudy(resStudyIds);
        Map<Id, Resource__c> resPlatformMap = instanceObj.getResPlatform(resPlatformIds);
        Map<Id, Id> resIdContentVersionIdMap = instanceObj.getContentVersionForStdDoc(
            resStudyMap,
            resPlatformMap
        );
        instanceObj.createWrapper(
            sendResults,
            resStudyMap,
            resPlatformMap,
            resIdContentVersionIdMap,
            patientVisitIds,
            updateWrapperlist
        );
        return updateWrapperlist;
    }

    @AuraEnabled
    public static Integer getSendResultCount(String initialLoadTime) {
        List<String> notificationsTypeList = new List<String>();
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_NEW_VISIT_RESULT_TYPE);
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED);
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED);
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED);
        DateTime initialDateTime = Datetime.valueOfGMT(initialLoadTime);
        UpdateService.ResourceFilter resFilter = UpdateService.getSendResultFilter();
        Integer updateCount = [
            SELECT COUNT()
            FROM Send_Result__c
            WHERE
                Notification__r.Target_Record_Ids__c != NULL
                AND CreatedDate <= :initialDateTime 
                AND Target_Type__c = :UpdateService.SR_TARGET_TYPE_UPDATES
                AND Status__c = :UpdateService.SR_STATUS_IN_PROGRESS
                AND Notification__r.Status__c = :UpdateService.SR_STATUS_IN_PROGRESS
                AND Notification__r.Recipient__c = :resFilter.participantContactId
                AND ((Notification__r.whatId__c IN :resFilter.peList
                AND Notification__r.Target_Record_Ids__c IN :resFilter.resStudyIdVisToPt)
                OR (Notification__r.whatId__c = :resFilter.currentPe
                AND Notification__r.Notification_Type__c IN :notificationsTypeList)
                OR Notification__r.whatId__c = :resFilter.currentParticipantId)
        ];
        return updateCount;
    }
    @AuraEnabled
    public static void removeUpdateCard(String sendResultId) {
        List<Id> notificationIds = new List<Id>();
        List<Send_Result__c> sendResultList = [
            SELECT id, Status__c, Notification__c
            FROM Send_Result__c
            WHERE Id = :sendResultId
        ];
        for (Send_Result__c sr : sendResultList) {
            sr.Status__c = 'Sent';
            notificationIds.add(sr.Notification__c);
        }
        update sendResultList;
        UpdateService.getInstance().updateNotificationsStatus(notificationIds);
    }

    @AuraEnabled
    public static void removeUpdateCardForVisitResult(
        String contactId,
        String peId,
        Id patientVisitId
    ) {
        List<Id> notificationIds = new List<Id>();
        List<Send_Result__c> sendResultList = [
            SELECT
                Id,
                Status__c,
                Notification__r.Recipient__c,
                Notification__r.Status__c,
                Notification__r.Notification_Type__c,
                Notification__r.WhatId__c,
                Notification__r.Target_Record_Ids__c
            FROM Send_Result__c
            WHERE
                Status__c = :UpdateService.SR_STATUS_IN_PROGRESS
                AND Notification__r.Status__c = :UpdateService.SR_STATUS_IN_PROGRESS
                AND Notification__r.Notification_Type__c = :NotificationCatalog.UPDATE_TO_PT_NEW_VISIT_RESULT_TYPE
                AND Notification__r.Recipient__c = :contactId
                AND Notification__r.WhatId__c = :peId
                AND Notification__r.Target_Record_Ids__c = :patientVisitId
        ];
        for (Send_Result__c sr : sendResultList) {
            sr.Status__c = 'Sent';
            notificationIds.add(sr.Notification__c);
        }
        try {
            update sendResultList;
            UpdateService.getInstance().updateNotificationsStatus(notificationIds);
        } catch (Exception e) {
            System.debug('error while updating send result:' + e.getMessage());
        }
    }
}
