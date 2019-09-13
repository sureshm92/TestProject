/**
 * Created by Kryvolap on 11.09.2019.
 */

trigger RPDelegateRelationshipTrigger on RP_Delegate_Relationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(RPDelegateRelationshipTriggerHandler.DeactivateUserWhenLastDelegationRemovedHandler.class);
}


