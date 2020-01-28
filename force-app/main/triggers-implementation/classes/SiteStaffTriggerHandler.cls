/**
 * Created by Kryvolap on 11.09.2019.
 */

public without sharing class SiteStaffTriggerHandler {
    public class DeactivateUserWhenLastDelegationRemovedHandler extends TriggerHandler {

        public override void afterDelete(List<SObject> oldList) {
            DelegateService.CheckAndDeactivateUsersForPI((List<Site_Staff__c>) oldList);
        }
    }

    public class AddConversationSharesHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            addConversationSharesForPITeam(newList);
        }
    }

    public class RemoveConversationSharesHandler extends TriggerHandler {
        public override void beforeDelete(List<SObject> oldList) {
            removeConversationSharesForPITeam(oldList);
        }
    }

    @TestVisible
    public static void addConversationSharesForPITeam(List<Site_Staff__c> staffs) {
        List<Site_Staff__c> newStaff = [
                SELECT Id, Site_Contact__c, Study_Site__c, Study_Site__r.Principal_Investigator__c
                FROM Site_Staff__c WHERE Id IN:staffs
        ];

        Set<Id> staffContactIds = new Set<Id>();
        Map<Id, List<Site_Staff__c>> staffByPIds = new Map<Id, List<Site_Staff__c>>();
        for(Site_Staff__c staff : newStaff) {
            staffContactIds.add(staff.Site_Contact__c);
            Id piCon = staff.Study_Site__r.Principal_Investigator__c;
            if(!staffByPIds.containsKey(piCon)) staffByPIds.put(piCon, new List<Site_Staff__c>());
            staffByPIds.get(piCon).add(staff);
        }

        List<User> staffUsers = [SELECT Id, ContactId FROM User WHERE ContactId IN:staffContactIds AND IsActive = TRUE];
        Map<Id, Id> staffUserByContact = new Map<Id, Id>();
        for(User staffUser : staffUsers) staffUserByContact.put(staffUser.ContactId, staffUser.Id);

        List<User> piUsers = [SELECT Id, ContactId FROM User WHERE ContactId IN:staffByPIds.keySet()];
        Map<Id, Id> piContactByUser = new Map<Id, Id>();
        for(User piUser : piUsers) piContactByUser.put(piUser.Id, piUser.ContactId);

        List<Conversation__Share> conversationShare = [
                SELECT
                        Id,
                        ParentId,
                        Parent.Participant_Enrollment__r.Study_Site__c,
                        UserOrGroupId
                FROM Conversation__Share WHERE UserOrGroupId IN:piUsers
        ];

        List<Conversation__Share> newShares = new List<Conversation__Share>();
        for(Conversation__Share cs : conversationShare) {
            Id piContact = piContactByUser.get(cs.UserOrGroupId);
            List<Site_Staff__c> piStaffs = staffByPIds.get(piContact);
            for(Site_Staff__c staff : piStaffs) {
                if(staff.Study_Site__c == cs.Parent.Participant_Enrollment__r.Study_Site__c
                        && staffUserByContact.containsKey(staff.Site_Contact__c)) {
                    newShares.add(new Conversation__Share(
                            AccessLevel = 'Edit',
                            ParentId = cs.ParentId,
                            UserOrGroupId = staffUserByContact.get(staff.Site_Contact__c)
                    ));
                }
            }
        }

        if(!newShares.isEmpty()) insert newShares;
    }

    @TestVisible
    public static void removeConversationSharesForPITeam(List<Site_Staff__c> staffs) {
        List<Id> staffContactIds = new List<Id>();
        List<Id> ssIds = new List<Id>();
        for (Site_Staff__c staff : staffs) {
            staffContactIds.add(staff.Site_Contact__c);
            ssIds.add(staff.Study_Site__c);
        }

        Map<Id, Conversation__c> conversationMap = new Map<Id, Conversation__c>([
                SELECT Id
                FROM Conversation__c
                WHERE Participant_Enrollment__r.Study_Site__c IN:ssIds
        ]);

        List<User> staffUsers = [SELECT Id FROM User WHERE ContactId IN:staffContactIds];
        List<Conversation__Share> conversationShares = [
                SELECT Id
                FROM Conversation__Share
                WHERE ParentId IN:conversationMap.keySet()
                AND UserOrGroupId IN:staffUsers
        ];
        if (!conversationShares.isEmpty()) delete conversationShares;
    }
}