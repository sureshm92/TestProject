/**
 * Created by AlexKetch on 6/18/2019.
 */

public with sharing class VisitConfigurationRemote {
    @auraEnabled
    public static List<Visit__c> getRelatedPlannedVisits(String visitPlanId) {
        System.debug('visitPlanId'+visitPlanId);
        return [
                SELECT Id,Name
                        ,Order__c
                        ,Timeplane__c
                        ,Visit_Plan__c
                        ,Visit_Schedule__c
                        ,Visit_Number__c
                        ,selected_icons__c
                FROM Visit__c
                WHERE Visit_Plan__c = :visitPlanId
        ];
    }

}