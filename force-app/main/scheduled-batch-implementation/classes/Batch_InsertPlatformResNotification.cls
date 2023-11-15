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
        Map<Id,Resource__c> resourceMap = new Map<Id,Resource__c>([SELECT Id,Expiration_Date__c from Resource__c WHERE Id In : resWithTherapeuticAreasMap.keyset()]);
        Map<Id, Contact> contactstoNotify = new Map<Id, Contact>();
        List<Notification__c> notificationsList = new List<Notification__c>();
        List<Id> participantContactIds = new List<Id>();
        Set<Id> participantIds = new Set<Id>();
        for (Therapeutic_Area_Patient__c tap : therapeuticAreaPatientsList) {
            if (!tap.Participant__r.Contact__r.UserCommunityIsDelegate__c) {
                participantContactIds.add(tap.Participant__r.Contact__c);
            }
            participantIds.add(tap.Participant__c);
        }
        Map<Id,Set<Id>> ptPatientDelMap = new Map<Id,Set<Id>>();
        for(Patient_Delegate_Enrollment__c pde : [SELECT Id,Patient_Delegate__r.Contact__c,Participant_Enrollment__r.Participant__c,Participant_Enrollment__r.Participant_Status__c,Participant_Enrollment__r.Participant__r.Has_Past_Studies__c,Participant_Enrollment__r.Participant__r.Has_Studies_In_Progress__c FROM Patient_Delegate_Enrollment__c WHERE Participant_Enrollment__r.Participant__c IN : participantIds and Participant_Enrollment__r.Invited_To_PP_Date__c !=null and Status__c='Active' ]){
            if(pde.Participant_Enrollment__r.Participant__r.Has_Past_Studies__c && !pde.Participant_Enrollment__r.Participant__r.Has_Studies_In_Progress__c){
                if(ptPatientDelMap.containsKey(pde.Participant_Enrollment__r.Participant__c)){
                    ptPatientDelMap.get(pde.Participant_Enrollment__r.Participant__c).add(pde.Patient_Delegate__r.Contact__c);
                }else{
                    ptPatientDelMap.put(pde.Participant_Enrollment__r.Participant__c,new Set<Id>{pde.Patient_Delegate__r.Contact__c});
                }
                
            }else if(pde.Participant_Enrollment__r.Participant__r.Has_Studies_In_Progress__c){
                if(!PEStatusState.PE_STATUS_GROUP_ALUMNI.contains(pde.Participant_Enrollment__r.Participant_Status__c)){
                    if(ptPatientDelMap.containsKey(pde.Participant_Enrollment__r.Participant__c)){
                        ptPatientDelMap.get(pde.Participant_Enrollment__r.Participant__c).add(pde.Patient_Delegate__r.Contact__c);
                    }else{
                        ptPatientDelMap.put(pde.Participant_Enrollment__r.Participant__c,new Set<Id>{pde.Patient_Delegate__r.Contact__c});
                    }
                }
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
                if (
                    String.isNotBlank(tap.Therapeutic_Area__c) &&
                    therapeuticAreaLang.therapeuticAreaIds.contains(tap.Therapeutic_Area__c)
                ) {
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
                    ((String.isNotBlank(tap.Participant__r.Contact__r.Language__c) &&
                      therapeuticAreaLang.langCodeList.contains(
                          tap.Participant__r.Contact__r.Language__c
                      )) ||
                     (String.isNotBlank(tap.Participant__r.Contact__r.Second_Choice_Language__c) &&
                      therapeuticAreaLang.langCodeList.contains(
                          tap.Participant__r.Contact__r.Second_Choice_Language__c
                      )) ||
                     (String.isNotBlank(tap.Participant__r.Contact__r.Third_Choice_Language__c) &&
                      therapeuticAreaLang.langCodeList.contains(
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
                    String.isNotBlank(tap.Therapeutic_Area__c) &&
                    notifyUser &&
                    therapeuticAreaLang.therapeuticAreaIds.contains(tap.Therapeutic_Area__c)
                ) {
                    String notificationType;
                    String notificationTypePush;
                    if (therapeuticAreaLang.resourceType == 'Article') {
                        notificationTypePush = NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_ARTICLE;
                        notificationType = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFROM_ARTICLE_TYPE;
                    }
                    if (therapeuticAreaLang.resourceType == 'Video') {
                        notificationTypePush = NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_VIDEO;
                        notificationType = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFORM_VIDEO_TYPE;
                    }
                    if (therapeuticAreaLang.resourceType == 'Multimedia') {
                        notificationTypePush = NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_MULTIMEDIA;
                        notificationType = NotificationCatalog.UPDATE_TO_PT_NEW_PLATFROMMULTIMEDIA_TYPE;
                    }
                    if (therapeuticAreaLang.resourceType == 'Relevant_Link') {
                        notificationTypePush = NotificationCatalog.PUSH_TO_PT_NEW_PLATFORM_LINK;
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
                    if(resourceMap.containsKey(resourceId) && (resourceMap.get(resourceId).Expiration_Date__c==null || (resourceMap.get(resourceId).Expiration_Date__c > Date.today()))){
                    	createPushnotifications(tap, resourceId,notificationTypePush,notificationsList,ptPatientDelMap); 
                    }
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
    public void createPushnotifications(Therapeutic_Area_Patient__c tap,Id resourceId,String notificationTypePush,List<Notification__c> notificationsList,Map<Id,Set<Id>> ptPatientDelMap){
        
        if(tap.Participant__r.Has_Studies_In_Progress__c){
            notificationsList.add(
                new Notification__c(
                    Recipient__c = tap.Participant__r.Contact__c,
                    WhatId__c = tap.Participant__c,
                    Notification_Type__c = notificationTypePush,
                    Target_Record_Ids__c = '' + resourceId
                )
            );
            if(ptPatientDelMap.containsKey(tap.Participant__c) && ptPatientDelMap.get(tap.Participant__c)!=null){
                for(Id delId : ptPatientDelMap.get(tap.Participant__c)){
                    notificationsList.add(
                        new Notification__c(
                            Recipient__c = delId,
                            WhatId__c = tap.Participant__c,
                            Notification_Type__c = notificationTypePush,
                            Target_Record_Ids__c = '' + resourceId
                        )
                    );
                }
            }
        }else if(!tap.Participant__r.Has_Studies_In_Progress__c && tap.Participant__r.Has_Past_Studies__c){
            notificationsList.add(
                new Notification__c(
                    Recipient__c = tap.Participant__r.Contact__c,
                    WhatId__c = tap.Participant__c,
                    Notification_Type__c = notificationTypePush,
                    Target_Record_Ids__c = '' + resourceId
                )
            );
            if(ptPatientDelMap.containsKey(tap.Participant__c) && ptPatientDelMap.get(tap.Participant__c)!=null){
                for(Id delId : ptPatientDelMap.get(tap.Participant__c)){ 
                    notificationsList.add(
                        new Notification__c(
                            Recipient__c = delId,
                            WhatId__c = tap.Participant__c,
                            Notification_Type__c = notificationTypePush,
                            Target_Record_Ids__c = '' + resourceId 
                        )
                    );
                }
            }
        }else if(!tap.Participant__r.Has_Studies_In_Progress__c && !tap.Participant__r.Has_Past_Studies__c){
            notificationsList.add(
                new Notification__c(
                    Recipient__c = tap.Participant__r.Contact__c,
                    WhatId__c = tap.Participant__c,
                    Notification_Type__c = notificationTypePush,
                    Target_Record_Ids__c = '' + resourceId
                )
            );
        }
    }
}