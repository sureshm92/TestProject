/**
 * Created by AlexKetch on 6/18/2019.
 */

public with sharing class VisitConfigurationRemote {
    @auraEnabled
    public static List<Visit__c> getRelatedPlannedVisits(String ctpId) {
        try {
            List<Clinical_Trial_Profile__c> ctps = [
                    SELECT Visit_Plan__c
                    FROM Clinical_Trial_Profile__c
                    WHERE Id = :ctpId
            ];
            if (String.isNotBlank(ctps[0].Visit_Plan__c)) {
                return [
                        SELECT Id,Name
                                ,Order__c
                                ,Timeplane__c
                                ,Visit_Plan__c
                                ,Visit_Schedule__c
                                ,Visit_Number__c
                                ,icons__c
                        FROM Visit__c
                        WHERE Visit_Plan__c = :ctps[0].Visit_Plan__c
                ];
            } else {
                return new List<Visit__c>();
            }

        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;

    }
    @auraEnabled
    public static List<Visit__c> updateCtp(String visitPlanId, String ctpId) {
        try {
            Clinical_Trial_Profile__c ctp = new Clinical_Trial_Profile__c(
                    Id = ctpId,
                    Visit_plan__c = visitPlanId
            );
            update ctp;

        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;

    }
    @auraEnabled
    public static void deleteVisit(String visitId) {
        try {
            Visit__c v = new Visit__c(Id = visitId);
            delete v;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }


}