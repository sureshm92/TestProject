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
            createPIUserOrSendNotification(newList, null);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createPIUserOrSendNotification(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }
    
    public class SwitchContactUserModeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            switchContactUserMode(newList);
        }
        
    }
    
    public class CreateStatusHistoryHandler extends TriggerHandler{
    
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createStatusHistory(newList, (Map<Id, Study_Site__c>)oldMap);
        }
    }
    
    public class PrepareAdditionalFieldsHandler extends TriggerHandler{
        
        public override void beforeInsert(List<SObject> newList) {
            prepareAdditionalFields(newList);
        }
    
    }
    
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void createPIUserOrSendNotification(List<Study_Site__c> newList, Map<Id, Study_Site__c> oldMap) {
        Set<Id> piContactIds = new Set<Id>();
        for (Study_Site__c ss : newList) if(ss.Principal_Investigator__c != null) piContactIds.add(ss.Principal_Investigator__c);
        Set<Id> contactIdsWithCreatedUser = new Set<Id>();
        for (User user : CommunityService.getCommunityUsersByContactIds(piContactIds)) contactIdsWithCreatedUser.add(user.ContactId);
        Set<Id> contactIdsForCreateUsers = new Set<Id>();
        Map<Id, String> contactsForSendNotificationMap = new Map<Id, String>();
        for(Study_Site__c ss : newList){
            if(ss.Override_PI_Referral_Status__c == StudySiteService.PI_S_INVITATION_SENT && ss.Principal_Investigator__c != null &&
                    (oldMap == null || (oldMap != null && ss.Override_PI_Referral_Status__c != oldMap.get(ss.Id).Override_PI_Referral_Status__c))){
                if(contactIdsWithCreatedUser.contains(ss.Principal_Investigator__c)){
                    contactsForSendNotificationMap.put(ss.Id, ss.Principal_Investigator__c);
                }else{
                    contactIdsForCreateUsers.add(ss.Principal_Investigator__c);
                }
            }
        }
        if(contactIdsForCreateUsers.size() > 0) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(contactIdsForCreateUsers);
        if(contactsForSendNotificationMap.size() > 0) SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_PI, contactsForSendNotificationMap);
    }
    
    @TestVisible
    private static void switchContactUserMode(List<Study_Site__c> studySites) {
        Set<Id> piContactIds = new Set<Id>();
        for (Study_Site__c ss : studySites) if (ss.Principal_Investigator__c != null) piContactIds.add(ss.Principal_Investigator__c);
        if (piContactIds.isEmpty()) return;
        List<Contact> contactsForUpdate = new List<Contact>();
        for (Contact piContact : CommunityService.getContactsByUserContactIds(piContactIds)) {
            piContact.userCommunityMode__c = CommunityService.USER_MODE_PI;
            if (piContact.userCommunytyType__c == null) {
                piContact.userCommunytyType__c = CommunityService.USER_MODE_PI;
            } else if(!piContact.userCommunytyType__c.contains(CommunityService.USER_MODE_PI)){
                piContact.userCommunytyType__c += ';' + CommunityService.USER_MODE_PI;
            }
            contactsForUpdate.add(piContact);
        }
        update contactsForUpdate;
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
    
    private static void prepareAdditionalFields(List<Study_Site__c> newList){
        List<Id> ctpIds = new List<Id>();
        List<Id> siteAccountIds = new List<Id>();
        List<Id> piIds = new List<Id>();
        for(Study_Site__c ss : newList){
            if(ss.Clinical_Trial_Profile__c != null) ctpIds.add(ss.Clinical_Trial_Profile__c);
            if(ss.Site__c != null) siteAccountIds.add(ss.Site__c);
            if(ss.Principal_Investigator__c != null) piIds.add(ss.Principal_Investigator__c);
        }
        Map<Id, Clinical_Trial_Profile__c> ctpMap = new Map<Id, Clinical_Trial_Profile__c>([
                SELECT Id, Protocol_ID__c
                FROM Clinical_Trial_Profile__c WHERE Id IN: ctpIds
        ]);
        Map<Id, Account> sitesMap = new Map<Id, Account>([
                SELECT Id, BillingCountryCode FROM Account WHERE Id IN: siteAccountIds
        ]);
        Map<Id, Contact> piMap = new Map<Id, Contact>([
                SELECT Id, Investigator_Key__c
                FROM Contact
                WHERE Id IN: piIds
        ]);
    
        for(Study_Site__c ss : newList){
            Clinical_Trial_Profile__c ctp;
            if(ss.Protocol_ID__c != null) ctp = ctpMap.get(ss.Clinical_Trial_Profile__c);
            Account site;
            if(ss.Site__c != null) site = sitesMap.get(ss.Site__c);
            Contact pi;
            if(ss.Principal_Investigator__c != null) pi = piMap.get(ss.Principal_Investigator__c);
            //Set autopopulated fields:
            //Primary_Key_ePR__c
            if(ctp != null && site != null && ss.Study_Site_Number__c != null){
                ss.Primary_Key_ePR__c = ctp.Protocol_ID__c + '_' + site.BillingCountryCode + '_' + ss.Study_Site_Number__c;
            }
            //Primary_Key__c
            if(ctp != null && pi != null){
                ss.Primary_Key__c = ss.Study_Site_Key__c + '_' + pi.Investigator_Key__c + '_' + ctp.Protocol_ID__c;
            }
        }
    }
}