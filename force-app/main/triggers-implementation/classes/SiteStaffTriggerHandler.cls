/**
 * Created by Kryvolap on 11.09.2019.
 */

public without sharing class SiteStaffTriggerHandler {

    public class DuplicateSiteStaffHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            List<Id> ConId = new List<Id>();
            List<Id> SiteId = new List<Id>();
           
            For(Site_Staff__c ss : (List<Site_Staff__c>)newList)
            {
                ConId.add(ss.Site_Contact__c);
                SiteId.add(ss.Study_Site__c);
            }
            List<Site_Staff__c> dupSitestaffLst = new List<Site_Staff__c>();
            dupSitestaffLst = [select id,Site_Contact__c,Study_Site__c,Delegate_Level__c from Site_Staff__c where Study_Site__c IN:SiteId and Site_Contact__c IN:ConId];
            if(dupSitestaffLst.size()>0)
            Delete dupSitestaffLst;
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


}