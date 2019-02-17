/* Created by D.Yasinskyi on 14.03.2018 */
public without sharing class StudySiteTriggerHandler {
    
    public static void onBeforeDelete(Map<Id, Study_Site__c> oldStudySites) {
        //delete status history
        deleteStatusHistory(oldStudySites);
    }
    public static void onAfterInsert(List<Study_Site__c> studySites) {
        //prepopulate contacts for PI procces
        prepopulateUserMode(studySites);
        //send notification to PI user [new StudySite] or create ne User(if not exist)
        sendNotification(studySites);
        
        //switch userMode:
        List<Contact> contacts = new List<Contact>();
        for(Study_Site__c ss : [SELECT Id, Principal_Investigator__c FROM Study_Site__c WHERE Id IN: studySites]){
            contacts.add(new Contact(
                    Id = ss.Principal_Investigator__c,
                    userCommunityMode__c = CommunityService.USER_MODE_PI
            ));
        }
        update contacts;
    }
    public static void onAfterUpdate(Map<Id, Study_Site__c> newStudySites, Map<Id, Study_Site__c> oldStudySites) {
        //prepopulate contacts for PI procces
        prepopulateUserModeOnUpdate(newStudySites, oldStudySites);
        //send notification to PI user [new StudySite] or create ne User(if not exist)
        sendNotificationOnUpdate(newStudySites, oldStudySites);
        //treck status history
        createStatusHistory(newStudySites, oldStudySites);
    }
    
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
    
    private static void sendNotificationOnUpdate(Map<Id, Study_Site__c> newStudySites, Map<Id, Study_Site__c> oldStudySites) {
        
        List<Study_Site__c> studySitesToSendNotification = new List<Study_Site__c>();
        
        for (Study_Site__c studySite : newStudySites.values()) {
            
            if ((oldStudySites.get(studySite.Id).Principal_Investigator__c != studySite.Principal_Investigator__c)
                    || (oldStudySites.get(studySite.Id).Override_PI_Referral_Status__c != studySite.Override_PI_Referral_Status__c)
                    ) {
                studySitesToSendNotification.add(studySite);
            }
        }
        sendNotification(studySitesToSendNotification);
    }
    
    private static void prepopulateUserModeOnUpdate(Map<Id, Study_Site__c> newStudySites, Map<Id, Study_Site__c> oldStudySites) {
        
        List<Study_Site__c> studySitesToPopulate = new List<Study_Site__c>();
        for (Study_Site__c studySite : newStudySites.values()) {
            if (oldStudySites.get(studySite.Id).Principal_Investigator__c != studySite.Principal_Investigator__c) {
                studySitesToPopulate.add(studySite);
            }
        }
        prepopulateUserMode(studySitesToPopulate);
    }
    
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
                
                if (userMode == null) {
                    studySiteContact.userCommunityMode__c = CommunityService.USER_MODE_PI;
                }
                if (userType == null || !userType.contains(CommunityService.USER_MODE_PI)) {
                    
                    if (userType == null) {
                        studySiteContact.userCommunytyType__c = CommunityService.USER_MODE_PI;
                    } else {
                        studySiteContact.userCommunytyType__c = userType + ';' + CommunityService.USER_MODE_PI;
                    }
                }
                if (!contactsToUpdate.containsKey(studySiteContact.Id)) {
                    contactsToUpdate.put(studySiteContact.Id, studySiteContact);
                }
            }
        }
        
        update contactsToUpdate.values();
    }
    
    private static void createStatusHistory(Map<Id, Study_Site__c> newStudySites, Map<Id, Study_Site__c> oldStudySites) {
        
        List<Status_History__c> historyList = new List<Status_History__c>();
        
        for (Study_Site__c studySite : newStudySites.values()) {
            
            if (oldStudySites.get(studySite.Id).Override_PI_Referral_Status__c != studySite.Override_PI_Referral_Status__c) {
                
                historyList.add(new Status_History__c(
                        Date__c = Datetime.now(),
                        StudySite__c = studySite.Id,
                        NewStatus__c = studySite.Override_PI_Referral_Status__c
                ));
            }
        }
        
        insert historyList;
    }
    
    private static void deleteStatusHistory(Map<Id, Study_Site__c> oldStudySites) {
        delete [SELECT Id FROM Status_History__c WHERE StudySite__c IN :oldStudySites.keySet()];
    }
}