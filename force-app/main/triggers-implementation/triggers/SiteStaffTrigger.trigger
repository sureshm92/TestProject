/**
 * Created by Kryvolap on 11.09.2019.
 */

trigger SiteStaffTrigger on Site_Staff__c(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete,
    after undelete
) {
    TriggerHandlerExecutor.execute(SiteStaffTriggerHandler.DuplicateSiteStaffHandler.class);
    TriggerHandlerExecutor.execute(
        SiteStaffTriggerHandler.DeactivateUserWhenLastDelegationRemovedHandler.class
    );
    TriggerHandlerExecutor.execute(SiteStaffTriggerHandler.RemoveConversationSharesHandler.class);
    TriggerHandlerExecutor.execute(SiteStaffTriggerHandler.AssignCommunitymodeAndTypeHandler.class);
}
