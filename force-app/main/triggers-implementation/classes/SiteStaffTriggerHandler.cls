/**
 * Created by Kryvolap on 11.09.2019.
 */

public without sharing class SiteStaffTriggerHandler {
    public class DuplicateSiteStaffHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            List<Id> ConId = new List<Id>();
            List<Id> SiteId = new List<Id>();

            for (Site_Staff__c ss : (List<Site_Staff__c>) newList) {
                ConId.add(ss.Site_Contact__c);
                SiteId.add(ss.Study_Site__c);
            }
            List<Site_Staff__c> dupSitestaffLst = new List<Site_Staff__c>();
            dupSitestaffLst = [
                SELECT id, Site_Contact__c, Study_Site__c, Delegate_Level__c
                FROM Site_Staff__c
                WHERE Study_Site__c IN :SiteId AND Site_Contact__c IN :ConId
            ];
            if (dupSitestaffLst.size() > 0)
                delete dupSitestaffLst;
        }
    }
    

    public class DeactivateUserWhenLastDelegationRemovedHandler extends TriggerHandler {
        public override void afterDelete(List<SObject> oldList) {
            //DelegateService.CheckAndDeactivateUsersForPI((List<Site_Staff__c>) oldList);
        }
    }

    //    public class AddConversationSharesHandler extends TriggerHandler {
    //        public override void afterInsert(List<SObject> newList) {
    //            DelegateService.addConversationSharesForPITeam(newList);
    //        }
    //    }

    public class RemoveConversationSharesHandler extends TriggerHandler {
        public override void beforeDelete(List<SObject> oldList) {
            DelegateService.removeConversationSharesForPITeam(oldList);
        }
    }

    public class AssignCommunitymodeAndTypeHandler extends TriggerHandler {

        public override void afterInsert(List<SObject> newList) 
        {
            AssignCommunitymodeAndType(newList);
        }      
    }

    @TestVisible
    private static void AssignCommunitymodeAndType(List<Site_Staff__c> newList) 
    {
        List<Contact> updatecontactList = new List<Contact>();
        Set<String> duplicatecontact = new Set<String>();
        Set<String> contactId = new Set<String>();

        for(Site_Staff__c ss : newList) 
        {
            if (ss.Site_Contact__c != null && !duplicatecontact.contains(ss.Site_Contact__c)) 
            {
                contactId.add(ss.Site_Contact__c);
            }
        }
        
        for(Contact cont : [Select id,userCommunityMode__c,userCommunytyType__c from Contact where Id IN: contactId])
        {
            boolean fromBackendVsUI = false;
            if(cont.userCommunityMode__c == null)
            {
                cont.userCommunityMode__c = CommunityService.USER_MODE_PI;
                fromBackendVsUI = true;
            }
            if(cont.userCommunytyType__c == null)
            {
                cont.userCommunytyType__c = CommunityService.USER_MODE_PI;
                fromBackendVsUI = true;
            }
            if(fromBackendVsUI == true)
            {
                updatecontactList.add(cont);
            }
        }
        if(!updatecontactList.isEmpty()) 
        {
            update updatecontactList;
        }
    }
}