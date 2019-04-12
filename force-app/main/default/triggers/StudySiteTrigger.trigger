/**
 * Created by Leonid Bartenev
 */

trigger StudySiteTrigger on Study_Site__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.PrepopulateUserModeHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.SwitchUserModeHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
}