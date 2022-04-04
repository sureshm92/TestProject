trigger SMSOptOutTrigger on SMS_Opt_Out__e(after insert) {
    TriggerHandlerExecutor.execute(SMSOptOutTriggerHandler.optOutSMS.class);
}
