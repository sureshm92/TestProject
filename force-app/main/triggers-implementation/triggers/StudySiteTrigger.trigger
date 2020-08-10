/**
 * Created by Leonid Bartenev
 */

trigger StudySiteTrigger on Study_Site__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.PrepareAdditionalFieldsHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreatePIOrSendNotificationHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.SwitchContactUserModeHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreateStatusHistoryHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.CreateHCPEnrollmentsForRPInWhiteListHandler.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.SetSuppressEmailsFieldAccordingToStudy.class);
    TriggerHandlerExecutor.execute(StudySiteTriggerHandler.AssignCommunityPermissionsForUser.class);

    // TODO: FIX FOR TRIGGER CONVENTIONS!
    if (Trigger.isAfter && Trigger.isUpdate) {
        ReferralNetworkService.sendEmails(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        ReferralNetworkService.sendEmails(Trigger.new, null);
    }
}
