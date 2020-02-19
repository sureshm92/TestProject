/**
 * Created by Nargiz Mamedova on 2/14/2020.
 */

public with sharing class FlowCOILookupRemote {

    @AuraEnabled
    public static void setCOILookup(String recordId, String chosenConditions){
        List<Therapeutic_Area_Assignment__c> existConditionAssignments = [
                SELECT Id, Therapeutic_Area__c FROM Therapeutic_Area_Assignment__c WHERE Resource__c =: recordId];
        delete existConditionAssignments;

        if (!chosenConditions.equals('none')) {
            List<Id> conditionIds = chosenConditions.split(';');
            List<Therapeutic_Area_Assignment__c> conditionAssignmentsToAdd = new List<Therapeutic_Area_Assignment__c>();
            for(Id c : conditionIds) {
                conditionAssignmentsToAdd.add(new Therapeutic_Area_Assignment__c(Therapeutic_Area__c = c, Resource__c = recordId));
            }
            insert conditionAssignmentsToAdd;
        }
    }
}