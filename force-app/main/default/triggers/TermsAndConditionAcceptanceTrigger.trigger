trigger TermsAndConditionAcceptanceTrigger on Terms_And_Conditions_Acceptance__c (after insert) {
   TriggerHandlerExecutor.execute(TermsAndConditionAcceptanceHandler.UpdateStudySitePIStatus.class);

}