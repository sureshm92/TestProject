trigger SMSDeliveryStatusTrigger on SMS_Delivery_Status__e (after insert) {
    TriggerHandlerExecutor.execute(SMSDeliveryStatusTriggerHandler.processDeliveryReciptforSMS.class);
}