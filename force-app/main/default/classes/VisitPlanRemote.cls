/**
 * Created by Igor Malyuta on 20.09.2019.
 */

public without sharing class VisitPlanRemote {

    public class VisitPlanWrapper {

        @AuraEnabled public Visit_Plan__c plan;
        @AuraEnabled public List<Icon_Details__c> iconDetails;
        @AuraEnabled public List<Visit__c> visits;
    }

    @AuraEnabled
    public static void upsertVisitPlan(String plan, String visits, String deletedVisits) {
        try {
            Visit_Plan__c newPlan = (Visit_Plan__c) JSON.deserialize(plan, Visit_Plan__c.class);
            upsert newPlan;

            List<Visit__c> visitsToUpsert = (List<Visit__c>) JSON.deserialize(visits, List<Visit__c>.class);
            List<Visit__c> visitsToDelete = (List<Visit__c>) JSON.deserialize(deletedVisits, List<Visit__c>.class);

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
                    if (v.Id != null) forDeleteVisits.add(v);
                }

                delete forDeleteVisits;
            }

            if (!newVisits.isEmpty()) insert newVisits;
            if (!updatedVisits.isEmpty()) upsert updatedVisits;

        } catch (Exception e) {
            AuraHelper.throwException(e);
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

    @AuraEnabled
    public static String cloneVisitPlan(String planId) {
        try {
            Visit_Plan__c plan = getVisitPlan(planId);
            List<Visit__c> visits = getVisits(plan.Id);
            List<Icon_Details__c> iconDetails = getIconDetails(plan.Id);

            Visit_Plan__c clonePlan = plan.clone();
            clonePlan.Name = clonePlan.Name + 'Clone';
            insert clonePlan;

            List<Visit__c> newVisits = new List<Visit__c>();
            for (Visit__c visit : visits) {
                newVisits.add(new Visit__c(
                        Icons__c = visit.Icons__c,
                        Name = visit.Name,
                        Order__c = visit.Order__c,
                        Patient_Portal_Name__c = visit.Patient_Portal_Name__c,
                        Visit_Number__c = visit.Visit_Number__c,
                        Visit_Plan__c = clonePlan.Id,
                        Visit_Schedule__c = visit.Visit_Schedule__c
                ));
            }

            List<Icon_Details__c> newIconDetails = new List<Icon_Details__c>();
            for (Icon_Details__c iconD : iconDetails) {
                newIconDetails.add(new Icon_Details__c(
                        Custom_Icon__c = iconD.Custom_Icon__c,
                        Description__c = iconD.Description__c,
                        Icons_package__c = iconD.Icons_package__c,
                        Name = iconD.Name,
                        Label__c = iconD.Label__c,
                        Visit_Plan__c = clonePlan.Id
                ));
            }

            insert newVisits;
            insert newIconDetails;

            VisitPlanWrapper wrapper = new VisitPlanWrapper();
            wrapper.plan = clonePlan;
            wrapper.visits = newVisits;
            return JSON.serialize(wrapper);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    public static Visit_Plan__c getVisitPlan(String planId) {
        return [SELECT Id, Name FROM Visit_Plan__c WHERE Id = :planId];
    }

    private static List<Visit__c> getVisits(String planId) {
        return [
                SELECT
                        Icons__c,
                        Name,
                        Order__c,
                        Patient_Portal_Name__c,
                        Visit_Number__c,
                        Visit_Schedule__c
                FROM Visit__c
                WHERE Visit_Plan__c = :planId
        ];
    }

    private static List<Icon_Details__c> getIconDetails(String planId) {
        return [
                SELECT
                        Custom_Icon__c,
                        Description__c,
                        Icons_package__c,
                        Name,
                        Label__c
                FROM Icon_Details__c
                WHERE Visit_Plan__c = :planId
        ];
    }
}