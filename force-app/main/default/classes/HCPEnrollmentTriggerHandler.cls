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
            sendNotification(newList);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            sendNotificationOnUpdate(newList, (Map<Id, HCP_Enrollment__c>)oldMap);
        }
    }
    
    public class PrepopulateUserModeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            prepopulateUserMode(newList);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            prepopulateUserModeOnUpdate(newList, (Map<Id, HCP_Enrollment__c>)oldMap);
        }
    }
    
    public class SwitchUserModeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
            switchUserMode(newList);
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
    private static void sendNotification(List<HCP_Enrollment__c> newList) {
        //prepare community users map:
        Set<Id> contactIds = new Set<Id>();
        List<HCP_Enrollment__c> processedHCPEList = new List<HCP_Enrollment__c>();
        for (HCP_Enrollment__c enrol : newList) {
            if (enrol.HCP_Contact__c != null && enrol.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT) {
                contactIds.add(enrol.HCP_Contact__c);
                processedHCPEList.add(enrol);
            }
        }
        if (contactIds.isEmpty()) return;
        Map<Id, User> communityUsersMap = new Map<Id, User>();
        for (User usr : CommunityService.getCommunityUsersByContactIds(contactIds)) communityUsersMap.put(usr.ContactId, usr);
        
        //prepare lists:
        Set<Id> contactIdsForCreateUser = new Set<Id>();
        Map<Id, String> hcpeMapForSend = new Map<Id, String>();
        for (HCP_Enrollment__c hcpe : processedHCPEList) {
            if (communityUsersMap.containsKey(hcpe.HCP_Contact__c)) {
                hcpeMapForSend.put(hcpe.Id, hcpe.HCP_Contact__c);
            } else {
                contactIdsForCreateUser.add(hcpe.HCP_Contact__c);
            }
        }

        //process lists:
        if (!contactIdsForCreateUser.isEmpty()) CommunityService.createPortalUsers(contactIdsForCreateUser);
        if (!hcpeMapForSend.isEmpty()) SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_HCP, hcpeMapForSend);
    }

    @TestVisible
    private static void sendNotificationOnUpdate(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        List<HCP_Enrollment__c> enrolmentsToSendNotification = new List<HCP_Enrollment__c>();
        for (HCP_Enrollment__c enrollment: newList) {
            if (oldMap.get(enrollment.Id).HCP_Contact__c != enrollment.HCP_Contact__c
                    || (enrollment.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT
                    && oldMap.get(enrollment.Id).Status__c != enrollment.Status__c)
                    ) {
                enrolmentsToSendNotification.add(enrollment);
            }
        }
        sendNotification(enrolmentsToSendNotification);
    }

    @TestVisible
    private static void prepopulateUserMode(List<HCP_Enrollment__c> newList) {
        Set<Id> hcpEContactIds = new Set<Id>();
        for (HCP_Enrollment__c enrol : newList) {
            if (enrol.HCP_Contact__c != null) hcpEContactIds.add(enrol.HCP_Contact__c);
        }
        if (hcpEContactIds.isEmpty()) return;
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact>();

        for (Contact hcpContact : CommunityService.getContactsByUserContactIds(hcpEContactIds)) {
            String userType = hcpContact.userCommunytyType__c;
            String userMode = hcpContact.userCommunityMode__c;
            if (userMode == null || userType == null || !userType.contains(CommunityService.USER_MODE_HCP)) {
                if (userMode == null) hcpContact.userCommunityMode__c = CommunityService.USER_MODE_HCP;
                if (userType == null || !userType.contains(CommunityService.USER_MODE_HCP)) {
                    if (userType == null) {
                        hcpContact.userCommunytyType__c = CommunityService.USER_MODE_HCP;
                    } else {
                        hcpContact.userCommunytyType__c = userType + ';' + CommunityService.USER_MODE_HCP;
                    }
                }
                if (!contactsToUpdate.containsKey(hcpContact.Id)) contactsToUpdate.put(hcpContact.Id, hcpContact);
            }
        }
        update contactsToUpdate.values();
    }

    @TestVisible
    private static void prepopulateUserModeOnUpdate(List<HCP_Enrollment__c> newList, Map<Id, HCP_Enrollment__c> oldMap) {
        List<HCP_Enrollment__c> enrollmentsToPopulate = new List<HCP_Enrollment__c>();
        for (HCP_Enrollment__c enrollment: newList) {
            if (oldMap.get(enrollment.Id).HCP_Contact__c != enrollment.HCP_Contact__c) {
                enrollmentsToPopulate.add(enrollment);
            }
        }
        prepopulateUserMode(enrollmentsToPopulate);
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
    
    @TestVisible
    private static void switchUserMode(List<HCP_Enrollment__c> newList){
        List<Contact> contacts = new List<Contact>();
        for(HCP_Enrollment__c hcpe : [SELECT Id, HCP_Contact__c FROM HCP_Enrollment__c WHERE Id IN: newList]){
            contacts.add(new Contact(
                    Id = hcpe.HCP_Contact__c,
                    userCommunityMode__c = CommunityService.USER_MODE_HCP
            ));
        }
        update contacts;

    }
}