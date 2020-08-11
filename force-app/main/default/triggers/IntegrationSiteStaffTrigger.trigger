/**
 * Created by Sumit Surve
 */
trigger IntegrationSiteStaffTrigger on Integration_Site_Staff__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    TriggerHandlerExecutor.execute(IntegrationSiteStaffTriggerHandler.CheckRequiredFieldsAndUpsertSiteStaff.class);
}