/**
 * Created by Kryvolap on 11.09.2019.
 */

public without sharing class RPDelegateRelationshipTriggerHandler {
    public class DeactivateUserWhenLastDelegationRemovedHandler extends TriggerHandler{

        public override void afterDelete(List<SObject> oldList) {
            DelegateService.CheckAndDeactivateUsersForHCP((List<RP_Delegate_Relationship__c>)oldList);
        }
    }
}