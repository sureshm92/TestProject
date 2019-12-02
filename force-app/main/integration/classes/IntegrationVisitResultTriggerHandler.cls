/**
 * Created by Denis Z on 08-Jul-19.
 */

public without sharing class IntegrationVisitResultTriggerHandler {

    public class CheckProcessedRecordsHandler extends TriggerHandler{

        public override void beforeInsert(List<SObject> newList) {
            setIsProcessed(newList, null);
        }

        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            setIsProcessed(newList, (Map<Id, Integration_VisitResult__c>)oldMap);
        }

    }

    private static void setIsProcessed(List<Integration_VisitResult__c> newList, Map<Id, Integration_VisitResult__c> oldMap){
        for(Integration_VisitResult__c visitResult : newList){
            if(oldMap == null || visitResult.MD5__c != oldMap.get(visitResult.Id).MD5__c){
                visitResult.Processed__c = false;
            }
        }
    }
}