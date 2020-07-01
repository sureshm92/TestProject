/**
 * Refactored by Leonid Bartenev
 */
trigger IntegrationReferralTrigger on Integration_Patient_Referral__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    Set<String> conditionOfInterestSet = new Set<String>(); 
    For(Integration_Patient_Referral__c ipr :Trigger.new)
    {
        conditionOfInterestSet.add(ipr.Condition_Of_Interests__c); 
    } 
    if(conditionOfInterestSet.contains('Covid-19'))
    {
        TriggerHandlerExecutor.execute(IntegrationPatientRefCovidTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class);
    }
    else
    {
        TriggerHandlerExecutor.execute(IntegrationPatientReferralTriggerHandler.CheckRequiredFieldsAndUpsertParticipantAndPEHandler.class);
    }
}