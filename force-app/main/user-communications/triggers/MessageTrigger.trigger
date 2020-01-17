/**
 * Created by Igor Malyuta on 24.12.2019.
 */

trigger MessageTrigger on Message__c (before insert, before update, before delete, after insert, after update, after delete) {
    TriggerHandlerExecutor.execute(MessageTriggerHandler.SendEmailHandler.class);
}