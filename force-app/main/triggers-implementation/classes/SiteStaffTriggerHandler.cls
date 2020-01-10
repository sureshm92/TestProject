/**
 * Created by Kryvolap on 11.09.2019.
 */

public without sharing class SiteStaffTriggerHandler {
    public class DeactivateUserWhenLastDelegationRemovedHandler extends TriggerHandler{

        public override void afterDelete(List<SObject> oldList) {
            DelegateService.CheckAndDeactivateUsersForPI((List<Site_Staff__c>)oldList);
        }
    }

    public class RemoveConversationSharesHandler extends TriggerHandler {
        public override void beforeDelete(List<SObject> oldList) {
            removeConversationSharesForPITeam(oldList);
        }
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