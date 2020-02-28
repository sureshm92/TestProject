/**
 * Created by Olga Skrynnikova on 1/20/2020.
 */

public with sharing class ContactReferralNetworkTriggerHandler {

    public class SyncContactInterestedSites extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            ReferralNetworkService.syncContactInterestedSites(newList);
        }

        public override void afterDelete(List<SObject> newList) {
            ReferralNetworkService.syncContactInterestedSites(newList);
        }
    }
}