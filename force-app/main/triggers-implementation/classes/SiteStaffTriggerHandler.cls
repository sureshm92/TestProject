/**
 * Created by Kryvolap on 11.09.2019.
 */

public without sharing class SiteStaffTriggerHandler {
    public class DeactivateUserWhenLastDelegationRemovedHandler extends TriggerHandler{

        public override void afterDelete(List<SObject> oldList) {
            DelegateService.CheckAndDeactivateUsersForPI((List<Site_Staff__c>)oldList);
        }
    }

    public class CreateConversationSharesHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            createConversationsSharesForPITeam(newList);
        }
    }

    public class RemoveConversationSharesHandler extends TriggerHandler {
        public override void beforeDelete(List<SObject> oldList) {
            removeConversationSharesForPITeam(oldList);
        }
    }

    @TestVisible
    private static void createConversationsSharesForPITeam(List<Site_Staff__c> staffs) {
        List<Site_Staff__c> siteStaffs = [
                SELECT Id, Site_Contact__c, Study_Site__r.Principal_Investigator__c
                FROM Site_Staff__c
                WHERE Id IN:staffs
        ];

        List<Id> staffContactIds = new List<Id>();
        Map<Id, List<Id>> staffContactsByPI = new Map<Id, List<Id>>();
        for(Site_Staff__c staff : siteStaffs) {
            Id piContId = staff.Study_Site__r.Principal_Investigator__c;
            if(!staffContactsByPI.containsKey(piContId)) staffContactsByPI.put(piContId, new List<Id>());

            staffContactsByPI.get(piContId).add(staff.Site_Contact__c);
            staffContactIds.add(staff.Site_Contact__c);
        }

        List<User> piUsers = [SELECT Id, ContactId FROM User WHERE ContactId IN:staffContactsByPI.keySet()];
        List<User> staffUsers = [SELECT Id, ContactId FROM User WHERE ContactId IN:staffContactIds];
        Map<Id, Id> staffUserByContact = new Map<Id, Id>();
        for(User u : staffUsers) staffUserByContact.put(u.ContactId, u.Id);

        Map<Id, List<Id>> staffUsersByPIUser = new Map<Id, List<Id>>();
        for(User pi : piUsers) {
            staffUsersByPIUser.put(pi.Id, new List<Id>());
            for(Id staffContact : staffContactsByPI.get(pi.ContactId)) {
                staffUsersByPIUser.get(pi.Id).add(staffUserByContact.get(staffContact));
            }
        }

        List<Conversation__Share> existingShares = [
                SELECT Id, AccessLevel, ParentId, UserOrGroupId
                FROM Conversation__Share
                WHERE UserOrGroupId IN:piUsers
        ];
        List<Conversation__Share> newShares = new List<Conversation__Share>();
        for(Conversation__Share exShare : existingShares) {
            for(Id staffUserId : staffUsersByPIUser.get(exShare.UserOrGroupId)) {
                newShares.add(new Conversation__Share(
                        AccessLevel = exShare.AccessLevel,
                        ParentId = exShare.ParentId,
                        UserOrGroupId = staffUserId
                ));
            }
        }
        if(!newShares.isEmpty()) insert newShares;
    }

    @TestVisible
    public static void removeConversationSharesForPITeam(List<Site_Staff__c> staffs) {
        List<Id> staffContactIds = new List<Id>();
        for(Site_Staff__c staff : staffs) staffContactIds.add(staff.Site_Contact__c);

        List<User> staffUsers = [SELECT Id FROM User WHERE ContactId IN:staffContactIds];
        List<Conversation__Share> conversationShares = [SELECT Id FROM Conversation__Share WHERE UserOrGroupId IN:staffUsers];
        if(!conversationShares.isEmpty()) delete conversationShares;
    }
}