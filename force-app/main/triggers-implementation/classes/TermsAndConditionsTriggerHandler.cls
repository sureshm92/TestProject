/**
 * Created by Igor Malyuta on 17.04.2019.
 */

public without sharing class TermsAndConditionsTriggerHandler {

    public class TCTriggerHandlerException extends Exception{}

    public class ActivePortalFieldsHandler extends TriggerHandler {
        public override void afterInsert(List<SObject> newList) {
            resetCheckBox(newList, null);
        }

        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            resetCheckBox(newList, (Map<Id, Terms_And_Conditions__c>) oldMap);
        }

        public void resetCheckBox(List<Terms_And_Conditions__c> newList, Map<Id, Terms_And_Conditions__c> oldMap) {
            List<Terms_And_Conditions__c> activeTCList = new List<Terms_And_Conditions__c>();
            List<String> commNames = new List<String>();
            for(Terms_And_Conditions__c tc : newList) {
                if(tc.Active__c == true && (oldMap == null || (oldMap != null && !oldMap.get(tc.Id).Active__c)) ) {
                    activeTCList.add(tc);
                    commNames.add(tc.Community_Name__c);
                }
            }
            if(activeTCList.size() > 1) throw new TCTriggerHandlerException('Only one Terms and Conditions can be active');

            if(!activeTCList.isEmpty()){
                List<Terms_And_Conditions__c> termsAndConditions = [
                        SELECT Id, Active__c
                        FROM Terms_And_Conditions__c
                        WHERE Active__c = TRUE AND Id NOT IN :activeTCList
                        AND Community_Name__c IN :commNames
                ];
                for(Terms_And_Conditions__c tc : termsAndConditions) tc.Active__c = false;
                update termsAndConditions;
            }
        }
    }
}