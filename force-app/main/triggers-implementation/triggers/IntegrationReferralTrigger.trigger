/**
 * Refactored by Leonid Bartenev
 */
trigger IntegrationReferralTrigger on Integration_Patient_Referral__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerHandlerExecutor.execute(IntegrationPatientReferralTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class);
}