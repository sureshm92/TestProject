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

    public class CreateRecruitingHCPStaffModeHandler extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
//            createDelegates(newList);
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
        Map<Id, Id> contactsForSendNotificationByPiMap = new Map<Id, Id>();
        Map<Id, HCP_Enrollment__c> newMap = new Map<Id, HCP_Enrollment__c>(newList);
        Map<Id,Contact> alreadyCreatedContactsMap = new Map<Id,Contact>([SELECT Id, Is_First_Logon__c FROM Contact WHERE Id IN :hcpContactIds AND Is_First_Logon__c = false]);
        List<Healthcare_Provider__c> hps = [SELECT Id, HCP_Enrollment__c FROM Healthcare_Provider__c WHERE HCP_Enrollment__c IN :newMap.keySet()];
        Map<Id, Healthcare_Provider__c> hpsByHCPE = new Map<Id, Healthcare_Provider__c>();
        for (Healthcare_Provider__c hp : hps) {
            hpsByHCPE.put(hp.HCP_Enrollment__c, hp);
        }
        for(HCP_Enrollment__c hcpe : newList){
            if(hcpe.Status__c == HCPEnrollmentService.HCP_S_INVITATION_SENT && hcpe.HCP_Contact__c != null &&
                    ((oldMap == null) || (oldMap != null && hcpe.Status__c != oldMap.get(hcpe.Id).Status__c))){
                if(contactIdsWithCreatedUser.contains(hcpe.HCP_Contact__c)){
                    if (hpsByHCPE.get(hcpe.Id) != null || alreadyCreatedContactsMap.containsKey(hcpe.HCP_Contact__c)) {
                        contactsForSendNotificationByPiMap.put(hcpe.Id, hcpe.HCP_Contact__c);
                    } else {
                        contactsForSendNotificationMap.put(hcpe.Id, hcpe.HCP_Contact__c);
                    }
                }else{
                    contactIdsForCreateUsers.add(hcpe.HCP_Contact__c);
                }
            }
        }

        if (contactIdsForCreateUsers.size() > 0) ((CommunityService) ClassFactory.newInstance(CommunityService.class)).createPortalUsers(contactIdsForCreateUsers);
        if (contactsForSendNotificationMap.size() > 0) SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_HCP, contactsForSendNotificationMap);
        if (contactsForSendNotificationByPiMap.size() > 0) SendEmailTemplate.sendEmailNotification(CommunityService.COMMUNITY_ET_HCP_BY_PI, contactsForSendNotificationByPiMap);
    }
    
    @TestVisible
    private static void switchContactUserMode(List<HCP_Enrollment__c> newList) {
        Set<Id> hcpEContactIds = new Set<Id>();
        for (HCP_Enrollment__c enrol : newList) {
            if (enrol.HCP_Contact__c != null) hcpEContactIds.add(enrol.HCP_Contact__c);
        }
        if (hcpEContactIds.isEmpty()) return;

// these changes are being on hold
// Map<Id, Participant__c> participants = CommunityService.getParticipantsByContactIds(hcpEContactIds);
        
        List<Contact> contactsForUpdate = new List<Contact>();
        for (Contact piContact : CommunityService.getContactsByUserContactIds(hcpEContactIds)) {
            piContact.userCommunityMode__c = CommunityService.USER_MODE_HCP;
            if (piContact.userCommunytyType__c == null) {
                piContact.userCommunytyType__c = CommunityService.USER_MODE_HCP;
            } else if(!piContact.userCommunytyType__c.contains(CommunityService.USER_MODE_HCP)){
                piContact.userCommunytyType__c += ';' + CommunityService.USER_MODE_HCP;
            }

// these changes are being on hold
//if (participants.containsKey(piContact.Id)) {
//    Participant__c participant = participants.get(piContact.Id);
//    piContact.FirstName = participant.First_Name__c;
//    piContact.LastName  = participant.Last_Name__c;
//    System.debug('-----------> HCPEnrollmentTriggerHandler.switchContactUserMode(): Contact names replaced to: ' + piContact.FirstName + ' ' + piContact.LastName);
//}
            
            contactsForUpdate.add(piContact);
        }
        update contactsForUpdate;
    }

//    @TestVisible
//    private static void createDelegates(List<HCP_Enrollment__c> newList) {
//        Set<Id> hcpEContactIds = new Set<Id>();
//        for (HCP_Enrollment__c enrol : newList) if (enrol.HCP_Contact__c != null) hcpEContactIds.add(enrol.HCP_Contact__c);
//        if (hcpEContactIds.isEmpty()) return;
//        Map<Id, Map<Id, String>> delegatesMapbyHCP = DelegateService.getHCPTeamLevelMapByHCP(hcpEContactIds);
//        List<Referring_HCP_Staff__c> newDelegateRecords = new List<Referring_HCP_Staff__c>();
//        for (HCP_Enrollment__c enrol : newList){
//            if (enrol.HCP_Contact__c != null) {
//                if(delegatesMapbyHCP.containsKey(enrol.HCP_Contact__c)){
//                    Map<Id, String> delegateMap = delegatesMapbyHCP.get(enrol.HCP_Contact__c);
//                    for(Id key: delegateMap.keySet()){
//                        Referring_HCP_Staff__c newDelegate = new Referring_HCP_Staff__c();
//                        newDelegate.Delegate_Level__c = delegateMap.get(key);
//                        newDelegate.Contact__c = key;
//                        newDelegate.HCP_Enrollment__c = enrol.Id;
//                        newDelegateRecords.add(newDelegate);
//                    }
//                }
//            }
//        }
//        if(!newDelegateRecords.isEmpty()){
//            insert newDelegateRecords;
//        }
//    }

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