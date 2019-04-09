/**
 * Created by Leonid Bartenev
 */

trigger TaskProcess on Task (before insert, before update, after insert) {
    TaskTriggerHandler.checkTaskFieldsBeforeInsert();
    TaskTriggerHandler.processSendImmediateEmails(Trigger.new);
}