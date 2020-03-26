/**
 * Created by Kryvolap on 11.09.2019.
 */

public without sharing class SiteStaffTriggerHandler {
    public class DeactivateUserWhenLastDelegationRemovedHandler extends TriggerHandler {

        public override void afterDelete(List<SObject> oldList) {
            DelegateService.CheckAndDeactivateUsersForPI((List<Site_Staff__c>) oldList);
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