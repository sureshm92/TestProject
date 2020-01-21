/**
 * Created by Olga Skrynnikova on 1/20/2020.
 */

public with sharing class ContactTherapeuticAreaTriggerHandler {
    public class SyncContactInterestedTopics extends TriggerHandler{

        public override void afterInsert(List<SObject> newList) {
            ReferralNetworkService.syncContactInterestedTopics(newList);
        }

        public override void afterDelete(List<SObject> newList) {
            ReferralNetworkService.syncContactInterestedTopics(newList);
        }
    }
}