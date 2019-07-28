/**
 * Created by Leonid Bartenev
 */

trigger TaskTrigger on Task (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(TaskTriggerHandler.CheckTaskFieldsWithTaskCodeHandler.class);
    TriggerHandlerExecutor.execute(TaskTriggerHandler.SendImmediateEmailsForTaskCodeHandler.class);
}