/**
 * Created by Leonid Bartenev
 */

trigger AlertTrigger on Alert__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(AlertTriggerHandler.ValidateFieldsHandler.class);
}