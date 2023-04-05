/**
 * Created by Sandeep on 17.03.2023.
 */
public without sharing class Batch_InsertPlatformResNotification implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Map<Id, Batch_CreatePlatformResourceNotification.ThereaputicAreaLang> resWithTherapeuticAreasMap = new Map<Id, Batch_CreatePlatformResourceNotification.ThereaputicAreaLang>();

    public Batch_InsertPlatformResNotification(
        Map<Id, Batch_CreatePlatformResourceNotification.ThereaputicAreaLang> resWithTherapeuticAreasMap
    ) {
        this.resWithTherapeuticAreasMap = resWithTherapeuticAreasMap;
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        List<Id> theraputicAreaIds = new List<Id>();
        for (Id resId : this.resWithTherapeuticAreasMap.keySet()) {
            theraputicAreaIds.addAll(this.resWithTherapeuticAreasMap.get(resId).therapeuticAreaIds);
        }
        return Database.getQueryLocator(
            [
                SELECT
                    Id,
                    Participant__r.Contact__c,
                    Participant__r.Contact__r.userCommunityDelegateId__c,
                    Participant__r.Contact__r.UserCommunityIsDelegate__c,
                    Participant__c,
                    Therapeutic_Area__c,
                    Participant__r.Contact__r.Resource_Notifications__c,
                    Participant__r.Contact__r.Third_Choice_Language__c,
                    Participant__r.Contact__r.Second_Choice_Language__c,
                    Participant__r.Contact__r.Language__c,
                    Participant__r.Has_Studies_In_Progress__c,
                    Participant__r.Has_Past_Studies__c
                FROM Therapeutic_Area_Patient__c
                WHERE
                    Participant__r.Contact__r.userCommunityMode__c = 'Participant'
                    AND Therapeutic_Area__c = :theraputicAreaIds
            ]
        );
    }
    public void execute(
        Database.BatchableContext param1,
        List<Therapeutic_Area_Patient__c> therapeuticAreaPatientsList
    ) {
        Map<Id, Contact> contactstoNotify = new Map<Id, Contact>();
        List<Notification__c> notificationsList = new List<Notification__c>();

        List<Id> participantContactIds = new List<Id>();
        for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatientsList) {
            if (!tap.Participant__r.Contact__r.UserCommunityIsDelegate__c) {
                participantContactIds.add(tap.Participant__r.Contact__c);
            }
        }
        for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatientsList) {
            Contact currentContact;
            if (contactstoNotify.get(tap.Participant__r.Contact__c) != null) {
                currentContact = contactstoNotify.get(tap.Participant__r.Contact__c);
            } else {
                currentContact = new Contact(
                    Id = tap.Participant__r.Contact__c,
                    Resource_Notifications__c = tap.Participant__r.Contact__r.Resource_Notifications__c
                );
            }
            Boolean notifyUser = false;
            for (Id resourceId : resWithTherapeuticAreasMap.keySet()) {
                notifyUser = false;
                Boolean isResourceVisible = false;
                Batch_CreatePlatformResourceNotification.ThereaputicAreaLang therapeuticAreaLang = resWithTherapeuticAreasMap.get(
                    resourceId
                );
                if (therapeuticAreaLang.therapeuticAreaIds.contains(tap.Therapeutic_Area__c)) {
                    if (
                        currentContact.Resource_Notifications__c == null ||
                        !currentContact.Resource_Notifications__c.contains(resourceId)
                    ) {
                        notifyUser = true;
                    }
                }
                if (notifyUser) {
                    notifyUser = false;
                    if (
                        therapeuticAreaLang.contentClass == 'Platform-TA' &&
                        tap.Participant__r.Has_Studies_In_Progress__c
                    ) {
                        notifyUser = true;
                    } else if (
                        (therapeuticAreaLang.contentClass == '3rd Party' ||
                        therapeuticAreaLang.resourceType == 'Relevant_Link') &&
                        !tap.Participant__r.Has_Studies_In_Progress__c
                    ) {
                        notifyUser = true;
                    }
                }
                if (
                    notifyUser &&
                    ((therapeuticAreaLang.langCodeList.contains(
                        tap.Participant__r.Contact__r.Language__c
                    )) ||
                    (therapeuticAreaLang.langCodeList.contains(
                        tap.Participant__r.Contact__r.Second_Choice_Language__c
                    )) ||
                    (therapeuticAreaLang.langCodeList.contains(
                        tap.Participant__r.Contact__r.Third_Choice_Language__c
                    )))
                ) {
                    notifyUser = true;

                    currentContact.Resource_Notifications__c = currentContact.Resource_Notifications__c !=
                        null
                        ? currentContact.Resource_Notifications__c + ';' + resourceId
                        : resourceId;
                } else {
                    notifyUser = false;
                }
                if (
                    notifyUser &&
                    therapeuticAreaLang.therapeuticAreaIds.contains(tap.Therapeutic_Area__c)
                ) {
                    String notificationType;
                    if (therapeuticAreaLang.resourceType == 'Article') {
                        notificationType = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFROM_ARTICLE_TYPE;
                    }
                    if (therapeuticAreaLang.resourceType == 'Video') {
                        notificationType = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE;
                    }
                    if (therapeuticAreaLang.resourceType == 'Multimedia') {
                        notificationType = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFROMMULTIMEDIA_TYPE;
                    }
                    if (therapeuticAreaLang.resourceType == 'Relevant_Link') {
                        notificationType = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_LINK_TYPE;
                    }
                    notificationsList.add(
                        new Notification__c(
                            Recipient__c = tap.Participant__r.Contact__c,
                            WhatId__c = tap.Participant__c,
                            Notification_Type__c = notificationType,
                            Target_Record_Ids__c = '' + resourceId
                        )
                    );
                    notifyUser = true;
                } else {
                    notifyUser = false;
                }
                if (notifyUser) {
                    contactstoNotify.put(currentContact.Id, currentContact);
                }
            }
        }

        if (contactstoNotify.size() > 0)
            update contactstoNotify.values();
        if (notificationsList.size() > 0)
            insert notificationsList;
    }
    public void finish(Database.BatchableContext param1) {
        system.debug('The job is finished');
    }
}
