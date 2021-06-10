trigger LLRHeventTrigger on LL_RH_event__e (after insert) {
    TriggerHandlerExecutor.execute(
        LLRHeventTriggerHandler.SendFOVtoAPI.class
    );
}