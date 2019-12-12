/**
 * Created by Olga Skrynnikova on 11/19/2019.
 */

trigger NotificationTrigger on Notification__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(NotificationTriggerHandler.CheckFieldsHandler.class);
}