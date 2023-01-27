/**
 * Created by Igor Malyuta on 20.09.2019.
 */

public without sharing class VisitPlanRemote {
    public class VisitPlanWrapper {
        @AuraEnabled
        public Visit_Plan__c plan;
        @AuraEnabled
        public List<Icon_Details__c> iconDetails;
        @AuraEnabled
        public List<Visit__c> visits;
    }

    @AuraEnabled
    public static Id upsertVisitPlan(
        String plan,
        String visits,
        String deletedVisits,
        String details
    ) {
        try {
            Visit_Plan__c newPlan = (Visit_Plan__c) JSON.deserialize(plan, Visit_Plan__c.class);
            upsert newPlan;

            List<Visit__c> visitsToUpsert = (List<Visit__c>) JSON.deserialize(
                visits,
                List<Visit__c>.class
            );
            List<Visit__c> visitsToDelete = (List<Visit__c>) JSON.deserialize(
                deletedVisits,
                List<Visit__c>.class
            );
            List<Icon_Details__c> iconDetails = (List<Icon_Details__c>) JSON.deserialize(
                details,
                List<Icon_Details__c>.class
            );

            List<Visit__c> newVisits = new List<Visit__c>();
            List<Visit__c> updatedVisits = new List<Visit__c>();
            for (Visit__c v : visitsToUpsert) {
                if (v.Id == null) {
                    v.Visit_Plan__c = newPlan.Id;
                    newVisits.add(v);
                } else {
                    updatedVisits.add(v);
                }
            }

            if (!String.isEmpty(deletedVisits)) {
                List<Visit__c> forDeleteVisits = new List<Visit__c>();
                for (Visit__c v : visitsToDelete) {
                    if (v.Id != null)
                        forDeleteVisits.add(v);
                }

                delete forDeleteVisits;
            }

            for (Icon_Details__c detail : iconDetails) {
                if (detail.Visit_Plan__c == null)
                    detail.Visit_Plan__c = newPlan.Id;
            }
            if (!iconDetails.isEmpty())
                upsert iconDetails;

            if (!newVisits.isEmpty())
                insert newVisits;
            if (!updatedVisits.isEmpty())
                upsert updatedVisits;
            return newPlan.Id;
        } catch (Exception e) {
            return (Id) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getVisitPlanWrapper(String planId) {
        try {
            VisitPlanWrapper wrapper = new VisitPlanWrapper();
            wrapper.plan = getVisitPlan(planId);
            wrapper.iconDetails = getIconDetails(wrapper.plan.Id);
            wrapper.visits = getVisits(wrapper.plan.Id);

            return JSON.serialize(wrapper);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    public static Visit_Plan__c getVisitPlan(String planId) {
        return [SELECT Id, Name, Version__c FROM Visit_Plan__c WHERE Id = :planId];
    }

    private static List<Visit__c> getVisits(String planId) {
        return [
            SELECT
                Icons__c,
                Name,
                Order__c,
                Patient_Portal_Name__c,
                Visit_Number__c,
                Visit_Description__c
            FROM Visit__c
            WHERE Visit_Plan__c = :planId
            ORDER BY Visit_Number__c NULLS LAST
        ];
    }

    private static List<Icon_Details__c> getIconDetails(String planId) {
        return [
            SELECT Custom_Icon__c, Description__c, Icons_package__c, Name, Label__c
            FROM Icon_Details__c
            WHERE Visit_Plan__c = :planId
            ORDER BY Name
        ];
    }
}
