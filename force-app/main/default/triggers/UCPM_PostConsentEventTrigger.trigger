trigger UCPM_PostConsentEventTrigger on UCPM_Post_Consent__e (after insert) {
    TriggerHandlerExecutor.execute(
        UCPM_PostConsentEventTriggerHandler.SendBulkImportRecordsToUCPM.class
    );
}