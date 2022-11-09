trigger RH_eConsentTrigger on RH_eConsent__e (after insert) {
  TriggerHandlerExecutor.execute(
        RH_eConsentEventTriggerHandler.UpdateConsentDetails.class
   );
}