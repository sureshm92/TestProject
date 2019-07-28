/**
 * Created by RAMukhamadeev on 2019-04-18.
 */

trigger ContactReferralNetworkTrigger on Contact_Referral_Network__c (after insert, after delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
        ReferralNetworkService.syncContactInterestedSites(Trigger.new);
    }

    if (Trigger.isAfter && Trigger.isDelete) {
        ReferralNetworkService.syncContactInterestedSites(Trigger.old);
    }
}