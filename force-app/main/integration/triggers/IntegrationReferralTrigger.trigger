/**
 * Refactored by Leonid Bartenev
 */
trigger IntegrationReferralTrigger on Integration_Patient_Referral__c(
    before insert
) {
    TriggerHandlerExecutor.execute(
            //IntegrationPatientReferralTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class
            IprEprTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class
        );
    
}