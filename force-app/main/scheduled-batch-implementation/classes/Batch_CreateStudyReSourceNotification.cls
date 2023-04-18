public class Batch_CreateStudyReSourceNotification implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Set<Id> ctpIds = new Set<Id>();

    public Batch_CreateStudyReSourceNotification(Set<Id> ctpIds) {
        this.ctpIds = ctpIds;
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Clinical_Trial_Profile__c,
                    Days_After_Enrolled__c,
                    Participant_Contact__c,
                    Participant_Contact__r.Language__c,
                    Participant_Contact__r.Participant_Opt_In_Status_Emails__c,
                    Participant_Contact__r.Resource_Notifications__c,
                    Participant_Contact__r.userCommunityMode__c,
                    Participant_Status__c,
                    Study_Site__r.Approved_Lng__c,
                    Study_Site__r.Site__r.BillingCountryCode,
                    Participant__r.Has_Studies_In_Progress__c,
                    Clinical_Trial_Profile__r.CommunityTemplate__c
                FROM Participant_Enrollment__c
                WHERE
                    Clinical_Trial_Profile__c IN :ctpIds
                    AND Study_Site__r.Approved_Lng__c != NULL
                    AND Participant__c != NULL
                    AND Participant_Contact__c != NULL
            ]
        );
    }

    public void execute(Database.BatchableContext bc, List<Participant_Enrollment__c> pelist) {
        List<Id> currentContextCtpIds = new List<Id>();
        Set<Id> resIds = new Set<Id>();
        Map<Id, List<String>> contentLangByResId = new Map<Id, List<String>>();

        for (Participant_Enrollment__c peObj : pelist) {
            currentContextCtpIds.add(peObj.Clinical_Trial_Profile__c);
        }
        List<Res_study__c> studyResourcesList = [
            SELECT
                Active_After_Days__c,
                Active_On_Status__c,
                Clinical_Trial_Profile__c,
                Expires_After_Days__c,
                Expires_On_Status__c,
                Id,
                Notify_On_Availability__c,
                Resource__c,
                Visible_In_Alumni__c,
                Visible_To_Delegates__c,
                Visible_To_Participant__c,
                Visible_To_PI__c,
                Visible_To_RP__c,
                Resource__r.Content_Type__c,
                Resource__r.document_type__c,
                Resource__r.Language__c,
                Resource__r.Languages__c,
                Resource__r.Countries__c
            FROM Res_study__c
            WHERE
                Visible_To_Participant__c = TRUE
                AND Clinical_Trial_Profile__c IN :currentContextCtpIds
        ];
        for (Res_study__c resStudyObj : studyResourcesList) {
            if (resStudyObj.Resource__r.Content_Type__c == 'Study_Document') {
                resIds.add(resStudyObj.Resource__c);
            } else {
                if (resStudyObj.Resource__r.Content_Type__c == 'Relevant_Link') {
                    if (contentLangByResId.containsKey(resStudyObj.Resource__c)) {
                        contentLangByResId.get(resStudyObj.Resource__c)
                            .addAll(resStudyObj.Resource__r.Languages__c.split(';'));
                    } else {
                        contentLangByResId.put(
                            resStudyObj.Resource__c,
                            resStudyObj.Resource__r.Languages__c.split(';')
                        );
                    }
                } else {
                    if (contentLangByResId.containsKey(resStudyObj.Resource__c)) {
                        contentLangByResId.get(resStudyObj.Resource__c)
                            .add(resStudyObj.Resource__r.Language__c);
                    } else {
                        contentLangByResId.put(
                            resStudyObj.Resource__c,
                            new List<String>{ resStudyObj.Resource__r.Language__c }
                        );
                    }
                }
            }
        }
        if (!resIds.isEmpty()) {
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT
                Id,
                LinkedEntityId,
                ContentDocument.Title,
                ContentDocument.LatestPublishedVersion.LanguageCode__c
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :resIds
        ];
        for (ContentDocumentLink content : contentDocumentLinks) {
            if (!contentLangByResId.containsKey(content.LinkedEntityId)) {
                contentLangByResId.put(content.LinkedEntityId, new List<String>());
            }
            contentLangByResId.get(content.LinkedEntityId)
                .add(content.ContentDocument.LatestPublishedVersion.LanguageCode__c);
            }
        }
        Map<Id, List<String>> resIdsByContactId = new Map<Id, List<String>>();
        List<Contact> contactToNotify = new List<Contact>();
        List<Notification__c> notifications = new List<Notification__c>();

        List<Id> partContIds = new List<Id>();
        for (Participant_Enrollment__c pe : pelist) {
            partContIds.add(pe.Participant_Contact__c);
        }
        Map<Id, List<Contact>> delContactsByParticipant = PatientDelegateEnrollmentService.getDelegatedCntsByParticipantCnt(
            partContIds,
            new List<String>{ 'Id', 'userCommunityMode__c', 'Resource_Notifications__c' }
        );

        for (Participant_Enrollment__c pe : pelist) {
            List<Contact> peContacts = new List<Contact>();
            peContacts.add(pe.Participant_Contact__r);
            if (delContactsByParticipant.containsKey(pe.Participant_Contact__c)) {
                peContacts.addAll(delContactsByParticipant.get(pe.Participant_Contact__c));
            }

            for (Res_study__c res : studyResourcesList) {
                if (pe.Clinical_Trial_Profile__c == res.Clinical_Trial_Profile__c) {
                for (Contact contact : peContacts) {
                    Boolean isDelegate = pe.Participant_Contact__c != contact.Id;
                        if (
                            (contact.userCommunityMode__c == null) ||
                            (!pe.Participant__r.Has_Studies_In_Progress__c &&
                            (res.Resource__r.Content_Type__c !=
                            ResourceService.RESOURCE_TYPE_RELEVANT_LINK &&
                            res.Resource__r.Content_Type__c !=
                            ResourceService.RESOURCE_RECORD_TYPE_NAME_STUDY_DOCUMENT))
                        )
                            continue;

                    if (
                        StudyResourceVisibilityService.isResourceVisibleForPE(
                            res,
                            pe,
                            contentLangByResId.get(res.Resource__c),
                            contact.userCommunityMode__c,
                            isDelegate
                        )
                    ) {
                        if (needNotify(contact, res.Resource__c)) {
                            contactToNotify.add(contact);
                            if (
                                res.Resource__r.document_type__c == 'Document' &&
                                res.Notify_On_Availability__c
                            ) {
                                notifications.add(
                                    new Notification__c(
                                        Recipient__c = contact.Id,
                                        WhatId__c = pe.Id,
                                        Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_STDDOC_TYPE,
                                            Target_Record_Ids__c = '' + res.Id
                                    )
                                );
                            }

                                if (
                                    pe.Clinical_Trial_Profile__r.CommunityTemplate__c ==
                                    CommunityTemplateService.TEMPLATE_PP && !isDelegate
                                ) {
                            if (res.Resource__r.Content_Type__c == 'Study_Document') {
                                notifications.add(
                                    new Notification__c(
                                        Recipient__c = contact.Id,
                                        WhatId__c = pe.Id,
                                        Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_DOC_TYPE,
                                            Target_Record_Ids__c = '' + res.Id
                                    )
                                );
                            }
                            if (res.Resource__r.Content_Type__c == 'Article') {
                                //Insert the notification for article
                                notifications.add(
                                    new Notification__c(
                                        Recipient__c = contact.Id,
                                        WhatId__c = pe.Id,
                                        Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_ARTICLE_TYPE,
                                            Target_Record_Ids__c = '' + res.Id
                                    )
                                );
                            }
                            if (res.Resource__r.Content_Type__c == 'Video') {
                                //Insert the notification for article
                                notifications.add(
                                    new Notification__c(
                                        Recipient__c = contact.Id,
                                        WhatId__c = pe.Id,
                                        Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_VIDEO_TYPE,
                                            Target_Record_Ids__c = '' + res.Id
                                    )
                                );
                            }
                            if (res.Resource__r.Content_Type__c == 'Relevant_Link') {
                                //insert the notification for relevant link
                                notifications.add(
                                    new Notification__c(
                                        Recipient__c = contact.Id,
                                        WhatId__c = pe.Id,
                                        Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_LINK_TYPE,
                                            Target_Record_Ids__c = '' + res.Id
                                    )
                                );
                            }
                            if (res.Resource__r.Content_Type__c == 'Multimedia') {
                                //insert the notification for relevant link
                                notifications.add(
                                    new Notification__c(
                                        Recipient__c = contact.Id,
                                        WhatId__c = pe.Id,
                                        Notification_Type__c = NotificationCatalog.UPDATE_TO_PT_NEW_MULTIMEDIA_TYPE,
                                            Target_Record_Ids__c = '' + res.Id
                                    )
                                );
                            }
                                }

                            if (!resIdsByContactId.containsKey(contact.Id)) {
                                List<String> resNotificationIds = contact.Resource_Notifications__c !=
                                    null
                                    ? contact.Resource_Notifications__c.split(';')
                                    : new List<String>();
                                resIdsByContactId.put(contact.Id, resNotificationIds);
                            }
                            resIdsByContactId.get(contact.Id).add(res.Resource__c);
                            }
                        }
                    }
                }
            }
        }
        if (!notifications.isEmpty())
            insert notifications;
        if (!contactToNotify.isEmpty()) {
            List<Contact> contactsToUpdate = new List<Contact>();
            for (Contact con : contactToNotify) {
                if (!resIdsByContactId.containsKey(con.Id))
                    continue;

                con.Resource_Notifications__c = String.join(resIdsByContactId.get(con.Id), ';');
                resIdsByContactId.remove(con.Id);
                contactsToUpdate.add(con);
            }
            update contactsToUpdate;
        }
    }

    public void finish(Database.BatchableContext param1) {
        system.debug('The job is finished');
    }
    private Boolean needNotify(Contact contact, Id resourceId) {
        Boolean notify = false;
        if (
            contact.Resource_Notifications__c == null ||
            !contact.Resource_Notifications__c.contains(resourceId)
        ) {
            notify = true;
        }
        return notify;
    }
}
