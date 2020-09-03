/**
 * Created by D.Yasinskyi on 23.02.2018
 * Refactored by Leonid Bartenev
 */
trigger HCPEnrollmentTrigger on HCP_Enrollment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.PrepareAdditionalFieldsHandler.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.DeleteStatusHistoryOnDeleteHandler.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.CreateHCPUserOrSendNotificationHandler.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.SwitchContactUserModeHandler.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.CreateStatusHistoryHandler.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.CreateRecruitingHCPStaffModeHandler.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.CheckReimbursableActivities.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.SendNotificationForActivatedHCPEHandler.class);
    TriggerHandlerExecutor.execute(HCPEnrollmentTriggerHandler.SendNotificationForDeclinedHCPEHandler.class);
}