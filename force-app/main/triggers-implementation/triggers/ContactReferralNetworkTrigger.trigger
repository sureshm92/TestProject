/**
 * Created by RAMukhamadeev on 2019-04-18.
 */

trigger ContactReferralNetworkTrigger on Contact_Referral_Network__c (after insert, after delete) {
    TriggerHandlerExecutor.execute(ContactReferralNetworkTriggerHandler.SyncContactInterestedSites.class);
}