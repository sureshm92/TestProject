/**
 * Refactored by Leonid Bartenev
 */
trigger IntegrationReferralTrigger on Integration_Patient_Referral__c(
    before insert, before update
) {
    TriggerHandlerExecutor.execute(
            //IntegrationPatientReferralTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class
            IprEprTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class
        );
        TriggerHandlerExecutor.execute(
            IprEprTriggerHandler.participantMinorCheck.class
        );
    
}