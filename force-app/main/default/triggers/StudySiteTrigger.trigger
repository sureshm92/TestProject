/**
 * Created by RAMukhamadeev on 2019-04-18.
 */

trigger StudySiteTrigger on Study_Site__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ReferralNetworkService.sendEmails(Trigger.new, Trigger.oldMap);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        ReferralNetworkService.sendEmails(Trigger.new, null);
    }
}