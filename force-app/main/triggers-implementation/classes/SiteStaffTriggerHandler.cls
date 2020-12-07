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
    
   /**  public class UpdateSiteStaffContactHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            List<Id> lstConId = new List<Id>();
            List<Contact> lstContacts = new List<Contact>();
            List<Contact> lstToUpdate = new List<COntact>();
            for (Site_Staff__c ss : (List<Site_Staff__c>) newList) {
                lstConId.add(ss.Site_Contact__c);
            }
            lstContacts = [select id,UserCommunityIsDelegate__c,userCommunityMode__c from contact where ID IN:lstConId and UserCommunityIsDelegate__c=false and userCommunityMode__c='PI'];
            if(lstContacts.size() > 0)
            {
              for(Contact c:lstContacts)
              {
                 contact con = new contact();
                 con.id = c.id;
                 con.UserCommunityIsDelegate__c=true;
                 lstToUpdate.add(con);
              }
                 update lstToUpdate;
            }

        }
    } */

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