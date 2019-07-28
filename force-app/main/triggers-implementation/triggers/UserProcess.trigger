/**
 * Created by Leonid Bartenev
 */

trigger UserProcess on User (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(UserTriggerHandler.UpdateEmailOnRelatedContactsHandler.class);
    TriggerHandlerExecutor.execute(UserTriggerHandler.UpdateLanguageOnRelatedContactsHandler.class);
    TriggerHandlerExecutor.execute(UserTriggerHandler.CreateCompleteYourProfileTaskHandler.class);
    TriggerHandlerExecutor.execute(UserTriggerHandler.UpdateUserRoleHandler.class);
}