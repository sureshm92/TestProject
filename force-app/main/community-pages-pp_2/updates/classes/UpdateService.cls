public without sharing class UpdateService {
    public class UpdateServiceException extends Exception {
    }
    public static String OBJECT_TYPE_STD_RESOURCE = 'res_study__c';
    public static String OBJECT_TYPE_PT_RESOURCE = 'resource__c';
    public static String OBJECT_TYPE_TELEVISIT = 'televisit__c';
    public static String OBJECT_TYPE_VISIT = 'visit__c';
    public static String OBJECT_TYPE_PATIENT_VISIT = 'patient_visit__c';
    public static String SR_STATUS_IN_PROGRESS = 'In Progress';
    public static String SR_TARGET_TYPE_UPDATES = 'Updates';
    public static String STD_DOC_CONTENT_TYPE = 'Study_Document';
    public static String ARTICLE_CONTENT_TYPE = 'Article';
    public static String MULTIMEDIA_CONTENT_TYPE = 'Multimedia';
    public static String VIDEO_CONTENT_TYPE = 'Video';
    public static String RELEVANT_LINK_CONTENT_TYPE = 'Relevant_Link';

    private static UpdateService instance;

    public static UpdateService getInstance() {
        if (instance == null)
            instance = new UpdateService();
        return instance;
    }

    public List<Send_Result__c> getSendResultRecords(
        List<Id> resStudyIds,
        List<Id> resPlatformIds,
        List<Id> patientVisitIds,
        Integer offsets,
        Integer limits,
        String initialLoadTime
    ) {
        List<String> notificationsTypeList = new List<String>();
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_NEW_VISIT_RESULT_TYPE);
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED);
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED);
        notificationsTypeList.add(NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED);
        DateTime initialDateTime = Datetime.valueOfGMT(initialLoadTime);
        ResourceFilter resFilter = getSendResultFilter();

        List<Send_Result__c> sendResults = [
            SELECT
                Id,
                Notification__c,
                Notification__r.Target_Record_Ids__c,
                Status__c,
                Notification__r.whatId__c,
                Notification__r.Notification_Type__c
            FROM Send_Result__c
            WHERE
                Notification__r.Target_Record_Ids__c != NULL
                AND CreatedDate <= :initialDateTime
                AND Target_Type__c = :SR_TARGET_TYPE_UPDATES
                AND Status__c = :SR_STATUS_IN_PROGRESS
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
            ORDER BY Notification__r.lastModifiedDate DESC
            LIMIT :limits
            OFFSET :offsets
        ];
        for (Send_Result__c sr : sendResults) {
            List<Id> targetIds = (List<Id>) sr.Notification__r.Target_Record_Ids__c.split(',');
            Id targetId = targetIds[targetIds.size() - 1];
            String targetType = targetId.getSObjectType().getDescribe().getName().toLowerCase();
            if (targetType == OBJECT_TYPE_STD_RESOURCE) {
                resStudyIds.add(sr.Notification__r.Target_Record_Ids__c);
            } else if (targetType == OBJECT_TYPE_PT_RESOURCE) {
                resPlatformIds.add(sr.Notification__r.Target_Record_Ids__c);
            } else if (targetType == OBJECT_TYPE_PATIENT_VISIT) {
                patientVisitIds.addAll(targetIds);
            }
        }
        return sendResults;
    }
    public Map<Id, Res_study__c> getResStudy(List<Id> resStudyIds) {
        Map<Id, Res_study__c> resStudyMap = new Map<Id, Res_study__c>();
        List<Res_study__c> studyResources = [
            SELECT
                id,
                RecordType.name,
                Resource__r.RecordType.DeveloperName,
                Resource__c,
                Resource__r.Content_Type__c,
                Resource__r.Title__c,
                Resource__r.Image__c,
                Resource__r.Posting_Date__c,
                Resource__r.Version_Date__c,
                Resource__r.URL__c,
                Resource__r.Type__c
            FROM Res_study__c
            WHERE Resource__c != NULL AND id IN :resStudyIds
            ALL ROWS
        ];
        for (Res_study__c res : studyResources) {
            resStudyMap.put(res.Id, res);
        }
        return resStudyMap;
    }
    public Map<Id, Resource__c> getResPlatform(List<Id> resPlatformIds) {
        List<Resource__c> platformResources = [
            SELECT
                Id,
                recordType.Name,
                RecordType.DeveloperName,
                Content_Type__c,
                Title__c,
                Image__c,
                Posting_Date__c,
                Version_Date__c,
                URL__c,
                Type__c
            FROM Resource__c
            WHERE Id IN :resPlatformIds
            ALL ROWS
        ];
        Map<Id, Resource__c> resPlatformMap = new Map<Id, Resource__c>();
        for (Resource__c res : platformResources) {
            resPlatformMap.put(res.Id, res);
        }
        return resPlatformMap;
    }
    public Map<Id, Id> getContentVersionForStdDoc(
        Map<Id, Res_study__c> resStudyMap,
        Map<Id, Resource__c> resPlatformMap
    ) {
        List<Id> resPlatformDocumentIds = new List<Id>();
        for (Res_study__c res : resStudyMap.values()) {
            if (res.resource__r.Content_Type__c == 'Study_Document') {
                resPlatformDocumentIds.add(res.resource__c);
            }
        }
        for (Resource__c res : resPlatformMap.values()) {
            if (res.Content_Type__c == 'Study_Document') {
                resPlatformDocumentIds.add(res.Id);
            }
        }
        Map<Id, Id> docIdResIdMap = new Map<Id, Id>();
        if (resPlatformDocumentIds.size() > 0) {
            List<ContentDocumentLink> contentDocLinks = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :resPlatformDocumentIds
            ];

            for (ContentDocumentLink cd : contentDocLinks) {
                docIdResIdMap.put(cd.ContentDocumentId, cd.LinkedEntityId);
            }
        }
        Map<Id, Id> resIdContentVersionId = new Map<Id, Id>();
        if (docIdResIdMap.size() > 0) {
            List<ContentVersion> contentVersionList = [
                SELECT ContentDocumentId, Id
                FROM ContentVersion
                WHERE ContentDocumentId IN :docIdResIdMap.keyset()
            ];
            for (ContentVersion cv : contentVersionList) {
                if (docIdResIdMap.containsKey(cv.ContentDocumentId)) {
                    resIdContentVersionId.put(docIdResIdMap.get(cv.ContentDocumentId), cv.Id);
                }
            }
        }
        return resIdContentVersionId;
    }
    public void createWrapper(
        List<Send_Result__c> sendResults,
        Map<Id, Res_study__c> resStudyMap,
        Map<Id, Resource__c> resPlatformMap,
        Map<Id, Id> resIdContentVersionIdMap,
        List<Id> patientVisitIds,
        List<UpdateWrapper> updateWrapperlist
    ) {
        Set<Id> televisitidset = new Set<Id>();
        for(Send_Result__c sr : sendResults){
            List<Id> targetIds = (List<Id>) sr.Notification__r.Target_Record_Ids__c.split(',');
            Id targetId = targetIds[targetIds.size() - 1];
            String targetType = targetId.getSObjectType().getDescribe().getName().toLowerCase();
            if (targetType == OBJECT_TYPE_TELEVISIT) {
                televisitidset.add(targetId);
            }
        }
        Map<ID, Televisit__c> televisitmap;
        if(televisitidset != null && televisitidset.size()> 0){
            televisitmap = new Map<ID, Televisit__c>([Select Id from Televisit__c where
                                            ID IN :televisitidset
                                            AND Participant_Enrollment__r.Study_Site__r.Override_PI_Referral_Status__c = 'Accepted'
                                            AND Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != null
                                            AND Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != 'Deactivated'
                                            AND Participant_Enrollment__r.Study_Site__r.Site_Activation_Status__c != 'Deactivated (Admin)']);

        } 
        for (Send_Result__c sr : sendResults) {
            List<Id> targetIds = (List<Id>) sr.Notification__r.Target_Record_Ids__c.split(',');
            Id targetId = targetIds[targetIds.size() - 1];
            String targetType = targetId.getSObjectType().getDescribe().getName().toLowerCase();
            UpdateWrapper wrp = new UpdateWrapper();
            if (
                targetType == OBJECT_TYPE_STD_RESOURCE ||
                targetType == OBJECT_TYPE_PT_RESOURCE ||
                targetType == OBJECT_TYPE_PATIENT_VISIT
            ) {
                wrp.updateType = 'resource';
                wrp.sendResultId = sr.Id;
                wrp.targetRecordId = targetId;
                if (targetType == OBJECT_TYPE_STD_RESOURCE) {
                    createResStudyWrapper(targetId, resStudyMap, wrp, resIdContentVersionIdMap);
                } else if (targetType == OBJECT_TYPE_PT_RESOURCE) {
                    createResPlatformWrapper(
                        targetId,
                        resPlatformMap,
                        wrp,
                        resIdContentVersionIdMap
                    );
                } else if (targetType == OBJECT_TYPE_PATIENT_VISIT) {
                    createPatientVisitWrapper(targetId, wrp);
                }
            } else if (targetType == OBJECT_TYPE_TELEVISIT) {
                if(televisitmap != null && televisitmap.containskey(targetId)){
                    wrp.sendResultId = sr.Id;
                    createTelevisitWrapper(wrp, sr);
                }else{
                    continue;
                }
            }
            updateWrapperlist.add(wrp);
        }
    }

    public void createPatientVisitWrapper(Id patientVisitId, UpdateWrapper wrp) {
        wrp.contentType = 'VisitResult';
        wrp.recId = patientVisitId;
    }

    public void createTelevisitWrapper(UpdateWrapper wrp, Send_Result__c sr) {
        wrp.contentType = 'Televisit';
        if (
            sr.Notification__r.Notification_Type__c ==
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_SCHEDULED
        ) {
            wrp.televisitType = 'Scheduled';
        } else if (
            sr.Notification__r.Notification_Type__c ==
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_CANCELED
        ) {
            wrp.televisitType = 'Canceled';
        } else if (
            sr.Notification__r.Notification_Type__c ==
            NotificationCatalog.UPDATE_TO_PT_TELEVISIT_RESCHEDULED
        ) {
            wrp.televisitType = 'Rescheduled';
        }
        //add check to set televisit Type from notification type
    }

    public void createResStudyWrapper(
        Id targetId,
        Map<Id, Res_study__c> resStudyMap,
        UpdateWrapper wrp,
        Map<Id, Id> resIdContentVersionIdMap
    ) {
        if (resStudyMap.containsKey(targetId) && resStudyMap.get(targetId).Resource__c != null) {
            wrp.Title = resStudyMap.get(targetId).Resource__r.Title__c;
            wrp.recId = resStudyMap.get(targetId).Resource__c;
            wrp.contentType = resStudyMap.get(targetId).Resource__r.Content_Type__c;
            wrp.resourceDevRecordType = resStudyMap.get(targetId)
                .Resource__r.RecordType.DeveloperName;
            if (resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Study_Document') {
                if (resIdContentVersionIdMap.containsKey(resStudyMap.get(targetId).Resource__c)) {
                    wrp.thumbnailDocId = resIdContentVersionIdMap.get(
                        resStudyMap.get(targetId).Resource__c
                    );
                }
                wrp.versionDate = resStudyMap.get(targetId).Resource__r.Version_Date__c;
            } else if (
                resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Article' ||
                resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Video' ||
                resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Multimedia'
            ) {
                wrp.thumbnailImage = resStudyMap.get(targetId).Resource__r.Image__c;
                wrp.versionDate = resStudyMap.get(targetId).Resource__r.Posting_Date__c;
            } else if (resStudyMap.get(targetId).Resource__r.Content_Type__c == 'Relevant_Link') {
                wrp.redirectLink = resStudyMap.get(targetId).Resource__r.URL__c;
                wrp.linkType = resStudyMap.get(targetId).Resource__r.Type__c;
                wrp.versionDate = resStudyMap.get(targetId).Resource__r.Posting_Date__c;
            }
        }
    }
    public void createResPlatformWrapper(
        Id targetId,
        Map<Id, Resource__c> resPlatformMap,
        UpdateWrapper wrp,
        Map<Id, Id> resIdContentVersionIdMap
    ) {
        if (resPlatformMap.containsKey(targetId)) {
            wrp.Title = resPlatformMap.get(targetId).Title__c;
            wrp.recId = targetId;
            wrp.contentType = resPlatformMap.get(targetId).Content_Type__c;
            wrp.versionDate = resPlatformMap.get(targetId).Version_Date__c;
            wrp.resourceDevRecordType = resPlatformMap.get(targetId).RecordType.DeveloperName;
            if (resPlatformMap.get(targetId).Content_Type__c == 'Study_Document') {
                wrp.thumbnailDocId = resIdContentVersionIdMap.get(resPlatformMap.get(targetId).Id);
            } else if (
                resPlatformMap.get(targetId).Content_Type__c == 'Article' ||
                resPlatformMap.get(targetId).Content_Type__c == 'Video' ||
                resPlatformMap.get(targetId).Content_Type__c == 'Multimedia'
            ) {
                wrp.thumbnailImage = resPlatformMap.get(targetId).Image__c;
                wrp.versionDate = resPlatformMap.get(targetId).Posting_Date__c;
            } else if (resPlatformMap.get(targetId).Content_Type__c == 'Relevant_Link') {
                wrp.redirectLink = resPlatformMap.get(targetId).URL__c;
                wrp.linkType = resPlatformMap.get(targetId).Type__c;
            }
        } else {
            wrp.recId = targetId;
            wrp.contentType = 'Multimedia';
            wrp.resourceDevRecordType = 'Multimedia';
        }
    }
    public static ResourceFilter getSendResultFilter() {
        ParticipantService.ParticipantState ps = ParticipantService.getInstance().getState();
        Id participantContact = ps.participant.Contact__c;
        Id currentParticipant = ps.participant.Id;
        Id currentContactId = CommunityService.getUserContact()?.Id;
        CommunityMode currentMode = UserContext.getCurrentUserMode();
        List<Id> resStudyIdVisToPt = new List<Id>();
        List<Id> resPlatformIdVisToPt = new List<Id>();
        List<Id> peList = new List<Id>();
        if (ps.pe != null) {
            Id currentStudy = ps.ctp.Id;
            Id currentPe = ps.pe.Id;
            List<Clinical_Trial_Profile__c> ctpValue = [
                SELECT
                    id,
                    Relevant_Links_Are_Available__c,
                    Study_Documents_Are_Available__c,
                    Video_And_Articles_Are_Available__c
                FROM Clinical_Trial_Profile__c
                WHERE id = :currentStudy
            ];
            Boolean RelevantLinksAvailable = ctpValue.get(0).Relevant_Links_Are_Available__c;
            Boolean StudyDocumentsAvailable = ctpValue.get(0).Study_Documents_Are_Available__c;
            Boolean VideoAndArticlesAvailable = ctpValue.get(0).Video_And_Articles_Are_Available__c;

            //For Platform
            for (Resource__c platformRes : [
                SELECT id, Content_Type__c
                FROM Resource__c
                WHERE
                    Content_Class__c = 'Platform-TA'
                    OR Content_Class__c = '3rd Party'
                    OR Content_Type__c = 'Relevant_Link'
            ]) {
                if (
                    String.isNotBlank(platformRes.Content_Type__c) &&
                    (platformRes.Content_Type__c == 'Study_Document' && StudyDocumentsAvailable) ||
                    (platformRes.Content_Type__c == 'Relevant_Link' && RelevantLinksAvailable) ||
                    ('Video;Article;Multimedia'.contains(platformRes.Content_Type__c) &&
                    VideoAndArticlesAvailable)
                ) {
                    resPlatformIdVisToPt.add(platformRes.Id);
                }
            }

            if (currentContactId == participantContact) {
                for (Res_study__c stdRes : [
                    SELECT
                        Clinical_Trial_Profile__c,
                        Id,
                        Visible_In_Alumni__c,
                        Visible_To_Delegates__c,
                        Visible_To_Participant__c,
                        Clinical_Trial_Profile__r.Study_Documents_Are_Available__c,
                        Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c,
                        Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c,
                        Resource__r.Content_Type__c
                    FROM Res_study__c
                    WHERE
                        Clinical_Trial_Profile__c = :currentStudy
                        AND Visible_To_Participant__c = TRUE
                ]) {
                    if (
                        String.isNotBlank(stdRes.Resource__r.Content_Type__c) &&
                        (stdRes.Resource__r.Content_Type__c == 'Study_Document' &&
                        stdRes.Clinical_Trial_Profile__r.Study_Documents_Are_Available__c) ||
                        (stdRes.Resource__r.Content_Type__c == 'Relevant_Link' &&
                        stdRes.Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c) ||
                        ('Video;Article;Multimedia'.contains(stdRes.Resource__r.Content_Type__c) &&
                        stdRes.Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c)
                    ) {
                        resStudyIdVisToPt.add(stdRes.Id);
                    }
                }
            } else if (currentContactId != participantContact) {
                for (Res_study__c stdRes : [
                    SELECT
                        Clinical_Trial_Profile__c,
                        Id,
                        Visible_In_Alumni__c,
                        Visible_To_Delegates__c,
                        Visible_To_Participant__c,
                        Clinical_Trial_Profile__r.Study_Documents_Are_Available__c,
                        Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c,
                        Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c,
                        Resource__r.Content_Type__c
                    FROM Res_study__c
                    WHERE
                        Clinical_Trial_Profile__c = :currentStudy
                        AND Visible_To_Participant__c = TRUE
                        AND Visible_To_Delegates__c = TRUE
                ]) {
                    if (
                        String.isNotBlank(stdRes.Resource__r.Content_Type__c) &&
                        (stdRes.Resource__r.Content_Type__c == 'Study_Document' &&
                        stdRes.Clinical_Trial_Profile__r.Study_Documents_Are_Available__c) ||
                        (stdRes.Resource__r.Content_Type__c == 'Relevant_Link' &&
                        stdRes.Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c) ||
                        ('Video;Article;Multimedia'.contains(stdRes.Resource__r.Content_Type__c) &&
                        stdRes.Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c)
                    ) {
                        resStudyIdVisToPt.add(stdRes.Id);
                    }
                }
                //For Platform
            }
            peList.add(currentPe);
        } else if (ps.pe == null) {
            for (Resource__c platformRes : [
                SELECT id, Content_Type__c
                FROM Resource__c
                WHERE Content_Class__c = '3rd Party' OR Content_Type__c = 'Relevant_Link'
            ]) {
                resPlatformIdVisToPt.add(platformRes.Id);
            }

            List<Id> pastCtpIds = new List<Id>();
            if (currentMode.isDelegate) {
                for (Patient_Delegate_Enrollment__c pde : [
                    SELECT
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__c
                    FROM Patient_Delegate_Enrollment__c
                    WHERE
                        Patient_Delegate__r.Contact__c = :ParticipantContext.getOwnParticipant()
                            .Contact__c
                        AND Patient_Delegate__r.Participant__r.Contact__c = :ParticipantContext.getCurrentContact()
                            .Id
                ]) {
                    peList.add(pde.Participant_Enrollment__c);
                    pastCtpIds.add(pde.Participant_Enrollment__r.Clinical_Trial_Profile__c);
                }
            } else {
                for (
                    Participant_Enrollment__c pastEnrollment : ContactService.getPastEnrollments(
                        participantContact
                    )
                ) {
                    if (
                        pastEnrollment.Invited_To_PP_Date__c != null &&
                        pastEnrollment.Clinical_Trial_Profile__r.Patient_Portal_Enabled__c
                    ) {
                        pastCtpIds.add(pastEnrollment.Clinical_Trial_Profile__c);
                        peList.add(pastEnrollment.Id);
                    }
                }
            }
            if (pastCtpIds.size() > 0) {
                for (Res_study__c stdRes : [
                    SELECT
                        Clinical_Trial_Profile__c,
                        Id,
                        Visible_In_Alumni__c,
                        Visible_To_Delegates__c,
                        Visible_To_Participant__c,
                        Clinical_Trial_Profile__r.Study_Documents_Are_Available__c,
                        Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c,
                        Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c,
                        Resource__r.Content_Type__c
                    FROM Res_study__c
                    WHERE
                        Resource__r.Content_Type__c = 'Relevant_Link' 
                        AND Clinical_Trial_Profile__c IN :pastCtpIds
                        AND Visible_In_Alumni__c = TRUE
                        AND Visible_To_Participant__c = TRUE
                ]) {
                    if (
                        String.isNotBlank(stdRes.Resource__r.Content_Type__c) &&
                        (stdRes.Resource__r.Content_Type__c == 'Study_Document' &&
                        stdRes.Clinical_Trial_Profile__r.Study_Documents_Are_Available__c) ||
                        (stdRes.Resource__r.Content_Type__c == 'Relevant_Link' &&
                        stdRes.Clinical_Trial_Profile__r.Relevant_Links_Are_Available__c) ||
                        ('Video;Article;Multimedia'.contains(stdRes.Resource__r.Content_Type__c) &&
                        stdRes.Clinical_Trial_Profile__r.Video_And_Articles_Are_Available__c)
                    ) {
                        resStudyIdVisToPt.add(stdRes.Id);
                    }
                }
            }
        }
        resourceFilter resFilter = new resourceFilter();
        resFilter.currentContactId = currentContactId;
        resFilter.participantContactId = participantContact;
        resFilter.resStudyIdVisToPt = resStudyIdVisToPt;
        resFilter.currentPe = ps?.pe?.Id;
        resFilter.peList = peList;
        resFilter.currentParticipantId = currentParticipant;
        resFilter.resPlatformIdVisToPt = resPlatformIdVisToPt;
        return resFilter;
    }
    public class ResourceFilter {
        public Id participantContactId;
        public Id currentParticipantId;
        public List<Id> resStudyIdVisToPt;
        public List<Id> peList;
        public Id currentContactId;
        public Id currentPe;
        public List<Id> resPlatformIdVisToPt;
    }

    public class UpdateWrapper {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String thumbnailImage;
        @AuraEnabled
        public String thumbnailDocId;
        @AuraEnabled
        public Id recId;
        @AuraEnabled
        public String resourceDevRecordType;
        @AuraEnabled
        public String redirectLink;
        @AuraEnabled
        public Date versionDate;
        @AuraEnabled
        public String updateType;
        @AuraEnabled
        public String contentType;
        @AuraEnabled
        public String linkType;
        @AuraEnabled
        public String targetRecordId;
        @AuraEnabled
        public String sendResultId;
        @AuraEnabled
        public String televisitType;
    }
    public void updateNotificationsStatus(List<Id> notificationIds) {
        List<Notification__c> notifications = [
            SELECT Id, (SELECT Id, Status__c FROM Send_Results__r)
            FROM Notification__c
            WHERE id IN :notificationIds
        ];
        for (Notification__c n : notifications) {
            if (n.Send_Results__r.isEmpty())
                continue;

            Boolean hasInProgress = false;
            for (Send_Result__c sr : n.Send_Results__r) {
                if (sr.Status__c == SR_STATUS_IN_PROGRESS)
                    hasInProgress = true;
            }
            if (!hasInProgress) {
                n.Status__c = NotificationService.NOTIFICATION_STATUS_PROCESSED;
            }
        }
        update notifications;
    }
    public void removeUpdateCardForResourceHandler(
        String targetRecId,
        String currentParticipant,
        String currentPe,
        String participantContact
    ) {
        List<Id> notificationIds = new List<Id>();
        List<String> targetIdList = new List<String>();
        List<Id> peList = new List<Id>();
        CommunityMode currentMode = UserContext.getCurrentUserMode();
        if (currentPe != null) {
            peList.add(currentPe);
        } else {
            if (currentMode.isDelegate) {
                for (Patient_Delegate_Enrollment__c pde : [
                    SELECT
                        Participant_Enrollment__c,
                        Participant_Enrollment__r.Clinical_Trial_Profile__c
                    FROM Patient_Delegate_Enrollment__c
                    WHERE
                        Patient_Delegate__r.Contact__c = :ParticipantContext.getOwnParticipant()
                            .Contact__c
                        AND Patient_Delegate__r.Participant__r.Contact__c = :ParticipantContext.getCurrentContact()
                            .Id
                ]) {
                    peList.add(pde.Participant_Enrollment__c);
                }
            } else {
                for (
                    Participant_Enrollment__c pastEnrollment : ContactService.getPastEnrollments(
                        participantContact
                    )
                ) {
                    peList.add(pastEnrollment.Id);
                }
            }
        }
        targetIdList.add(targetRecId);
        for (Res_study__c stdRes : [
            SELECT Id, Resource__c
            FROM Res_study__c
            WHERE Resource__c = :targetRecId
        ]) {
            targetIdList.add(stdRes.Id);
        }
        List<Send_Result__c> sendResults = [
            SELECT id, Status__c, Notification__c
            FROM Send_Result__c
            WHERE
                Notification__r.Recipient__c = :participantContact
                AND Notification__r.WhatId__c != NULL
                AND Notification__r.Status__c = :SR_STATUS_IN_PROGRESS
                AND Status__c = :SR_STATUS_IN_PROGRESS
                AND Notification__r.Target_Record_Ids__c IN :targetIdList
                AND (Notification__r.WhatId__c = :currentParticipant
                OR Notification__r.WhatId__c IN :peList)
        ];
        for (Send_Result__c sr : sendResults) {
            sr.Status__c = 'Sent';
            if (!notificationIds.contains(sr.Notification__c)) {
                notificationIds.add(sr.Notification__c);
            }
        }
        if (sendResults.size() > 0) {
            update sendResults;
        }
        if (notificationIds.size() > 0) {
            UpdateService.getInstance().updateNotificationsStatus(notificationIds);
        }
    }

    public void processUpdateNotifications(
        List<String> notificationTypes,
        String contactId,
        String peId,
        String participantId,
        Id patientVisitId,
        String sendResultId,
        String sourceMethod
    ) {
        List<Id> notificationIds = new List<Id>();
        String baseFilter = '';
        if (sourceMethod == 'removeUpdateCard') {
            baseFilter = DatabaseService.fieldEqual('Id', sendResultId);
        } else {
            baseFilter =
                DatabaseService.fieldEqual('Status__c', UpdateService.SR_STATUS_IN_PROGRESS) +
                'AND ' +
                DatabaseService.fieldEqual(
                    'Notification__r.Status__c',
                    UpdateService.SR_STATUS_IN_PROGRESS
                ) +
                'AND ' +
                DatabaseService.fieldInValues(
                    'Notification__r.Notification_Type__c',
                    notificationTypes
                ) +
                'AND ' +
                DatabaseService.fieldEqual('Notification__r.Recipient__c', contactId);

            if (sourceMethod == 'removeUpdateCardForTelevisit') {
                baseFilter =
                    baseFilter +
                    'AND (' +
                    DatabaseService.fieldEqual('Notification__r.WhatId__c', peId) +
                    'OR ' +
                    DatabaseService.fieldEqual('Notification__r.WhatId__c', participantId) +
                    ')';
            }
            if (sourceMethod == 'removeUpdateCardForVisitResult') {
                baseFilter =
                    baseFilter +
                    'AND ' +
                    DatabaseService.fieldEqual('Notification__r.WhatId__c', peId) +
                    'AND ' +
                    DatabaseService.fieldEqual(
                        'Notification__r.Target_Record_Ids__c',
                        patientVisitId
                    );
            }
        }
        List<Send_Result__c> sendResultList = (List<Send_Result__c>) DatabaseService.query(
            new List<String>{ 'Id', 'Status__c', 'Notification__c' },
            Send_Result__c.getSObjectType(),
            baseFilter
        );
        for (Send_Result__c sr : sendResultList) {
            sr.Status__c = 'Sent';
            notificationIds.add(sr.Notification__c);
        }
        try {
            update sendResultList;
            updateNotificationsStatus(notificationIds);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}