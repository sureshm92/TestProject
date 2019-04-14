/**
 * Created by D.Yasinskyi on 23.02.2018
 * Refactored by Leonid Bartenev
 */

public without sharing class HCPEnrollmentTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class PrepareAdditionalFieldsHandler extends TriggerHandler{
        
        public override void beforeInsert(List<SObject> newList) {
            prepareAdditionalFields(newList);
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepareAdditionalFields(newList);
        }
    }
    
    public class DeleteStatusHistoryOnDeleteHandler extends TriggerHandler{
        
        public override void beforeDelete(List<SObject> oldList) {
            deleteStatusHistory(oldList);
        }
    }
    
    public class CreateHCPUserOrSendNotificationHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            createHCPUserOrSendNotification(newList, null);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createHCPUserOrSendNotification(newList, (Map<Id, HCP_Enrollment__c>)oldMap);
        }
    }
    
    public class SwitchContactUserModeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            switchContactUserMode(newList);
        }
    }
    
    public class CreateStatusHistoryHandler extends TriggerHandler{
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            createStatusHistory(newList, (Map<Id, HCP_Enrollment__c>)oldMap);
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void prepareAdditionalFields(List<HCP_Enrollment__c> newList){
        Set<Id> ssIds = new Set<Id>();
        for(HCP_Enrollment__c hcpe : newList) if(hcpe.Study_Site__c != null) ssIds.add(hcpe.Study_Site__c);
        Map<Id, Study_Site__c> studySiteMap = new Map<Id, Study_Site__c>([
                SELECT Id, Principal_Investigator__c,
                        Clinical_Trial_Profile__c
                FROM Study_Site__c WHERE Id IN: ssIds
        ]);
        for(HCP_Enrollment__c hcpe : newList){
            if(hcpe.Study_Site__c != null){
                Study_Site__c ss = studySiteMap.get(hcpe.Study_Site__c);
                if(ss != null) {
                    hcpe.Study_Site_PI_Contact__c = ss.Principal_Investigator__c;
                    hcpe.Clinical_Trial_Profile__c = ss.Clinical_Trial_Profile__c;
                }
            }
        }
    }

    @TestVisible
    private static void createHCPUserOrSendNotification(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        Set<Id> hcpContactIds = new Set<Id>();
        for(HCP_Enrollment__c hcpe : newList) if(hcpe.HCP_Contact__c != null) hcpContactIds.add(hcpe.HCP_Contact__c);
        Set<Id> contactIdsWithCreatedUser = new Set<Id>();
        for(User user : CommunityService.getCommunityUsersByContactIds(hcpContactIds)) contactIdsWithCreatedUser.add(user.ContactId);
        Set<Id> contactIdsForCreateUsers = new Set<Id>();
        Map<Id, Id> contactsForSendNotificationMap = new Map<Id, Id>();
        for(HCP_Enrollment__c hcpe : newList){
            if(hcpe.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT && hcpe.HCP_Contact__c != null &&
                    ((oldMap == null) || (oldMap != null && hcpe.Status__c != oldMap.get(hcpe.Id).Status__c))){
                if(contactIdsWithCreatedUser.contains(hcpe.HCP_Contact__c)){
                    contactsForSendNotificationMap.put(hcpe.Id, hcpe.HCP_Contact__c);
                }else{
                    contactIdsForCreateUsers.add(hcpe.HCP_Contact__c);
                }
            }
        }
        if (contactIdsForCreateUsers.size() > 0) CommunityService.createPortalUsers(contactIdsForCreateUsers);
        if (contactsForSendNotificationMap.size() > 0) SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_HCP, contactsForSendNotificationMap);
    }
    
    @TestVisible
    private static void switchContactUserMode(List<HCP_Enrollment__c> newList) {
        Set<Id> hcpEContactIds = new Set<Id>();
        for (HCP_Enrollment__c enrol : newList) if (enrol.HCP_Contact__c != null) hcpEContactIds.add(enrol.HCP_Contact__c);
        if (hcpEContactIds.isEmpty()) return;
        List<Contact> contactsForUpdate = new List<Contact>();
        for (Contact piContact : CommunityService.getContactsByUserContactIds(hcpEContactIds)) {
            piContact.userCommunityMode__c = CommunityService.USER_MODE_HCP;
            if (piContact.userCommunytyType__c == null) {
                piContact.userCommunytyType__c = CommunityService.USER_MODE_HCP;
            } else if(!piContact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)){
                piContact.userCommunytyType__c += ';' + CommunityService.USER_MODE_HCP;
            }
            contactsForUpdate.add(piContact);
        }
        update contactsForUpdate;
    }

    @TestVisible
    private static void createStatusHistory(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        List<Status_History__c> hcpEHistoryList = new List<Status_History__c>();
        for (HCP_Enrollment__c enrollment: newList) {
            if (oldMap.get(enrollment.Id).Status__c != enrollment.Status__c) {
                hcpEHistoryList.add(new Status_History__c(
                        Date__c = Datetime.now(),
                        HCP_Enrollment__c = enrollment.Id,
                        NewStatus__c = enrollment.Status__c
                ));
            }
        }
        insert hcpEHistoryList;
    }

    @TestVisible
    private static void deleteStatusHistory(List<HCP_Enrollment__c> oldList) {
        delete [SELECT Id FROM Status_History__c WHERE HCP_Enrollment__c IN: oldList];
    }
    
}