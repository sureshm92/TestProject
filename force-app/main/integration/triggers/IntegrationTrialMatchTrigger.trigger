/**
 * Created by Nargiz Mamedova on 4/28/2020.
 */

trigger IntegrationTrialMatchTrigger on Integration_Trial_Match__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationTrialMatchTriggerHandler.class);
}