public without sharing class ScreenerResponseTriggerHandler {
    
    public class CheckReimbursableActivities extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            ProviderPaymentsService.checkPEForReimbursableActivities(
                (List<Participant_PrescreenerResponse__c>) newList,
                null
            );
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            ProviderPaymentsService.checkPEForReimbursableActivities(
                (List<Participant_PrescreenerResponse__c>) newList,
                (Map<Id, Participant_PrescreenerResponse__c>) oldMap
            );
        }
    }
}