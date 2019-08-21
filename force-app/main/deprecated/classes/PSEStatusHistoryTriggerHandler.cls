/**
 * Created by Leonid Bartenev
 */

public without sharing class PSEStatusHistoryTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class UpdatePSEStatusOnHistoryChangeHandler extends TriggerHandler{
        
        public override void afterInsert(List<SObject> newList) {
//            updatePSEStatuses(newList);
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
//            updatePSEStatuses(newList);
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
//    @TestVisible
//    private static void updatePSEStatuses(List<PSE_Status_History__c> newList){
//        Set<Id> pseListIds = new Set<Id>();
//        for(PSE_Status_History__c pseStatusHistory : newList) pseListIds.add(pseStatusHistory.PSE__c);
//
//        List<Participant_Study_Enrollment__c> pseList = [
//                SELECT Id, (SELECT Id, Status__c FROM PSE_Status_Histories__r ORDER BY Changed_Date__c DESC LIMIT 1)
//                FROM Participant_Study_Enrollment__c
//                WHERE Id IN: pseListIds
//        ];
//        List<Participant_Study_Enrollment__c> pseListForUpdate = new List<Participant_Study_Enrollment__c>();
//        for(Participant_Study_Enrollment__c pse : pseList){
//            if(pse.PSE_Status_Histories__r.size() > 0){
//                pse.Status__c = pse.PSE_Status_Histories__r[0].Status__c;
//                pseListForUpdate.add(pse);
//            }
//        }
//        update pseListForUpdate;
//    }
}