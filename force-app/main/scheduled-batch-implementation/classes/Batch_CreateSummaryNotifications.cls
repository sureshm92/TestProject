/**
 * Created by Igor Malyuta on 11.09.2019.
 */

public without sharing class Batch_CreateSummaryNotifications extends Batch_ScheduledAbstract {
    public Database.QueryLocator start(Database.BatchableContext param1) {
        return Database.getQueryLocator(
            [
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
                    Resource__r.Content_Type__c
                FROM Res_study__c
                WHERE
                    Notify_On_Availability__c = TRUE
                    AND Visible_To_Participant__c = TRUE
                    AND Resource__r.document_type__c = 'Document'
                    AND Clinical_Trial_Profile__r.Study_Documents_Are_Available__c = TRUE
            ]
        );
    }

    public void execute(Database.BatchableContext param1, List<Res_study__c> resStudies) {
        Map<Id, List<Res_study__c>> resStudyByCtp = new Map<Id, List<Res_study__c>>();
        Set<Id> resIds = new Set<Id>();
        for (Res_study__c res : resStudies) {
            if (!resStudyByCtp.containsKey(res.Clinical_Trial_Profile__c)) {
                resStudyByCtp.put(res.Clinical_Trial_Profile__c, new List<Res_study__c>());
            }
            resStudyByCtp.get(res.Clinical_Trial_Profile__c).add(res);
            resIds.add(res.Resource__c);
        }

        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT
                Id,
                LinkedEntityId,
                ContentDocument.Title,
                ContentDocument.LatestPublishedVersion.LanguageCode__c
            FROM ContentDocumentLink
            WHERE LinkedEntityId IN :resIds
        ];

        Map<Id, List<String>> contentLangByResId = new Map<Id, List<String>>();
        for (ContentDocumentLink content : contentDocumentLinks) {
            if (!contentLangByResId.containsKey(content.LinkedEntityId)) {
                contentLangByResId.put(content.LinkedEntityId, new List<String>());
            }
            contentLangByResId.get(content.LinkedEntityId)
                .add(content.ContentDocument.LatestPublishedVersion.LanguageCode__c);
        }

        List<Participant_Enrollment__c> enrollment = [
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
                Study_Site__r.Approved_Lng__c
            FROM Participant_Enrollment__c
            WHERE
                Clinical_Trial_Profile__c IN :resStudyByCtp.keySet()
                AND Study_Site__r.Approved_Lng__c != NULL
                AND Participant__c != NULL
                AND Participant_Contact__c != NULL
        ];

        Map<Id, List<String>> resIdsByContactId = new Map<Id, List<String>>();
        List<Contact> contactToNotify = new List<Contact>();
        List<Notification__c> notifications = new List<Notification__c>();

        List<Id> partContIds = new List<Id>();
        for (Participant_Enrollment__c pe : enrollment)
            partContIds.add(pe.Participant_Contact__c);
        Map<Id, List<Contact>> delContactsByParticipant = PatientDelegateEnrollmentService.getDelegatedCntsByParticipantCnt(
            partContIds,
            new List<String>{ 'Id', 'userCommunityMode__c', 'Resource_Notifications__c' }
        );

        for (Participant_Enrollment__c pe : enrollment) {
            List<Contact> peContacts = new List<Contact>();
            peContacts.add(pe.Participant_Contact__r);
            if (delContactsByParticipant.containsKey(pe.Participant_Contact__c)) {
                peContacts.addAll(delContactsByParticipant.get(pe.Participant_Contact__c));
            }

            for (Res_study__c res : resStudyByCtp.get(pe.Clinical_Trial_Profile__c)) {
                for (Contact contact : peContacts) {
                    Boolean isDelegate = pe.Participant_Contact__c != contact.Id;
                    if (contact.userCommunityMode__c == null)
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
                            notifications.add(
                                new Notification__c(
                                    Recipient__c = contact.Id,
                                    WhatId__c = pe.Id,
                                    Notification_Type__c = NotificationCatalog.MESSAGE_TO_PT_NEW_STDDOC_TYPE
                                )
                            );

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

    public override Type getType() {
        return Batch_CreateSummaryNotifications.class;
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

    public override String getBatchDescription() {
        return 'This job sends Emails and SMS when new Study Document is available';
    }

    public override String getRecommendedIntervalMode() {
        return Batch_ScheduledAbstract.INTERVAL_HOURS;
    }

    public override Integer getRecommendedRelaunchInterval() {
        return 1;
    }
}
