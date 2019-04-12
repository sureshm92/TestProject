/**
 * Created by D.Yasinskyi on 14.03.2018
 * refactored by Leonid Bartenev
 */

public without sharing class StudySiteTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class DeleteStatusHistoryOnDeleteHandler extends TriggerHandler{
        
        public override void beforeDelete(List<SObject> oldList) {
            deleteStatusHistory(oldList);
        }
    }
    
    public class CreatePIOrSendNotificationHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            sendNotification(newList);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendNotificationOnUpdate(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }
    
    public class PrepopulateUserModeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            prepopulateUserMode(newList);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepopulateUserModeOnUpdate(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }
    
    public class SwitchUserModeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            switchUserMode(newList);
        }
    }
    
    public class CreateStatusHistoryHandler extends TriggerHandler{
    
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createStatusHistory(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void sendNotification(List<Study_Site__c> studySites) {
        Set<Id> contactIds = new Set<Id>();
        List<Study_Site__c> processedStudySites = new List<Study_Site__c>();
        for (Study_Site__c studySite : studySites) {
            if (studySite.Principal_Investigator__c != null && studySite.Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT) {
                contactIds.add(studySite.Principal_Investigator__c);
                processedStudySites.add(studySite);
            }
        }
        if (contactIds.isEmpty()) return;
        
        Map<Id, User> communityUsers = new Map<Id, User>();
        for (User usr : CommunityService.getCommunityUsersByContactIds(contactIds)) communityUsers.put(usr.ContactId, usr);
        
        Set<Id> toCreateUser = new Set<Id>();
        Map<Id, String> toSendNotificationMap = new Map<Id, String>();
        
        for (Study_Site__c ss : processedStudySites) {
            if (communityUsers.containsKey(ss.Principal_Investigator__c)) {
                toSendNotificationMap.put(ss.Id, ss.Principal_Investigator__c);
            } else {
                toCreateUser.add(ss.Principal_Investigator__c);
            }
        }
        
        if (!toCreateUser.isEmpty()) CommunityService.createPortalUsers(toCreateUser);
        if (!toSendNotificationMap.isEmpty()) SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_PI, toSendNotificationMap);
    }
    
    @TestVisible
    private static void sendNotificationOnUpdate(List<Study_Site__c> newStudySites, Map<Id, Study_Site__c> oldMap) {
        List<Study_Site__c> studySitesToSendNotification = new List<Study_Site__c>();
        for (Study_Site__c ss : newStudySites) {
            if ((oldMap.get(ss.Id).Principal_Investigator__c != ss.Principal_Investigator__c)
                    || (oldMap.get(ss.Id).Override_PI_Referral_Status__c != ss.Override_PI_Referral_Status__c)) {
                studySitesToSendNotification.add(ss);
            }
        }
        sendNotification(studySitesToSendNotification);
    }
    
    @TestVisible
    private static void prepopulateUserModeOnUpdate(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap) {
        List<Study_Site__c> studySitesToPopulate = new List<Study_Site__c>();
        for (Study_Site__c studySite : newList) {
            if (oldMap.get(studySite.Id).Principal_Investigator__c != studySite.Principal_Investigator__c) {
                studySitesToPopulate.add(studySite);
            }
        }
        prepopulateUserMode(studySitesToPopulate);
    }
    
    @TestVisible
    private static void prepopulateUserMode(List<Study_Site__c> studySites) {
        Set<Id> studySiteContactIds = new Set<Id>();
        for (Study_Site__c studySite : studySites) {
            if (studySite.Principal_Investigator__c != null) {
                studySiteContactIds.add(studySite.Principal_Investigator__c);
            }
        }
        if (studySiteContactIds.isEmpty()) return;
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();
        for (Contact studySiteContact : CommunityService.getContactsByUserContactIds(studySiteContactIds)) {
            String userType = studySiteContact.userCommunytyType__c;
            String userMode = studySiteContact.userCommunityMode__c;
            if (userMode == null || userType == null || !userType.contains(CommunityService.USER_MODE_PI)) {
                if (userMode == null) studySiteContact.userCommunityMode__c = CommunityService.USER_MODE_PI;
                if (userType == null || !userType.contains(CommunityService.USER_MODE_PI)) {
                    if (userType == null) {
                        studySiteContact.userCommunytyType__c = CommunityService.USER_MODE_PI;
                    } else {
                        studySiteContact.userCommunytyType__c = userType + ';' + CommunityService.USER_MODE_PI;
                    }
                }
                if (!contactsToUpdate.containsKey(studySiteContact.Id)) contactsToUpdate.put(studySiteContact.Id, studySiteContact);
            }
        }
        update contactsToUpdate.values();
    }
    
    @TestVisible
    private static void switchUserMode(List<Study_Site__c> newList) {
        List<Contact> contacts = new List<Contact>();
        for(Study_Site__c ss : [SELECT Id, Principal_Investigator__c FROM Study_Site__c WHERE Id IN: newList]){
            contacts.add(new Contact(
                    Id = ss.Principal_Investigator__c,
                    userCommunityMode__c = CommunityService.USER_MODE_PI
            ));
        }
        update contacts;
    }
    
    @TestVisible
    private static void createStatusHistory(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap) {
        List<Status_History__c> historyList = new List<Status_History__c>();
        for (Study_Site__c studySite : newList) {
            if (oldMap.get(studySite.Id).Override_PI_Referral_Status__c != studySite.Override_PI_Referral_Status__c) {
                historyList.add(new Status_History__c(
                        Date__c = Datetime.now(),
                        StudySite__c = studySite.Id,
                        NewStatus__c = studySite.Override_PI_Referral_Status__c
                ));
            }
        }
        insert historyList;
    }
    
    @TestVisible
    private static void deleteStatusHistory(List<Study_Site__c> oldList) {
        delete [SELECT Id FROM Status_History__c WHERE StudySite__c IN: oldList];
    }
}