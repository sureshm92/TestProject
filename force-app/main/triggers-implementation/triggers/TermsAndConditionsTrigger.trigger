/**
 * Created by Igor Malyuta on 17.04.2019.
 */

trigger TermsAndConditionsTrigger on Terms_And_Conditions__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(TermsAndConditionsTriggerHandler.ActivePortalFieldsHandler.class);
}