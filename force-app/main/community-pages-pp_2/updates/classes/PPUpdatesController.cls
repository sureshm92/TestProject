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
                OR (Notification__r.whatId__c = :resFilter.currentParticipantId 
                AND Notification__r.Target_Record_Ids__c IN :resFilter.resPlatformIdVisToPt)
                OR (Notification__r.whatId__c = :resFilter.currentParticipantId
                AND Notification__r.Notification_Type__c IN :notificationsTypeList))
        ];
        return updateCount;
    }
    /* Process Resource Updates when clicked */
    @AuraEnabled
    public static void removeUpdateCard(String sendResultId) {
        UpdateService.getInstance()
            .processUpdateNotifications(
                new List<String>(),
                null,
                null,
                null,
                null,
                sendResultId,
                'removeUpdateCard'
            );
    }

    @AuraEnabled
    public static void removeUpdateCardForVisitResult(
        String contactId,
        String peId,
        Id patientVisitId
    ) {
        List<String> visitResultType = new List<String>{
            NotificationCatalog.UPDATE_TO_PT_NEW_VISIT_RESULT_TYPE
        };
        UpdateService.getInstance()
            .processUpdateNotifications(
                visitResultType,
                contactId,
                peId,
                null,
                patientVisitId,
                null,
                'removeUpdateCardForVisitResult'
            );
    }

    @AuraEnabled
    public static void removeScheduledAndRescheduledUpdateNotifications(
        String contactId,
        String peId,
        string participantId
    ) {
        List<String> scheduledAndRescheduled = new List<String>{
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED,
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED
        };
        UpdateService.getInstance()
            .processUpdateNotifications(
                scheduledAndRescheduled,
                contactId,
                peId,
                participantId,
                null,
                null,
                'removeUpdateCardForTelevisit'
            );
    }

    @AuraEnabled
    public static void removeCancelledUpdateNotifications(
        String contactId,
        String peId,
        string participantId
    ) {
        List<String> scheduledAndRescheduled = new List<String>{
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED
        };
        UpdateService.getInstance()
            .processUpdateNotifications(
                scheduledAndRescheduled,
                contactId,
                peId,
                participantId,
                null,
                null,
                'removeUpdateCardForTelevisit'
            );
    }
    /* Process Notifications from Resource Page */
    @AuraEnabled
    public static void removeUpdateCardForResource(
        String targetRecId,
        String currentParticipant,
        String currentPe,
        String participantContact
    ) {
        try {
            UpdateService instanceObj = UpdateService.getInstance();
            instanceObj.removeUpdateCardForResourceHandler(
                targetRecId,
                currentParticipant,
                currentPe,
                participantContact
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}