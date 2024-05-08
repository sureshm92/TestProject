trigger Integration_UCPM_Org_PP_Trigger on Integration_UCPM_Org_PP__c(
  before insert,
  after insert
) {
  TriggerHandlerExecutor.execute(
    Integration_UCPM_TriggerHandler.ProcessResponse.class
  );
}