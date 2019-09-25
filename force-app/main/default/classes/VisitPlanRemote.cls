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
    public static String createVisitPlanWithVisits(String plan, String visits) {
        try {
            Visit_Plan__c newPlan = (Visit_Plan__c) JSON.deserialize(plan, Visit_Plan__c.class);
            upsert newPlan;

            List<Visit__c> newVisits = (List<Visit__c>) JSON.deserialize(visits, List<Visit__c>.class);
            for(Visit__c v : newVisits) v.Visit_Plan__c = newPlan.Id;
            upsert newVisits;

            return JSON.serialize(plan);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String getVisitPlanWrapper(String planId) {
        try {
            VisitPlanWrapper wrapper = new VisitPlanWrapper();
            wrapper.plan = [SELECT Id, Name FROM Visit_Plan__c WHERE Id =: planId];

            wrapper.iconDetails = [
                    SELECT
                            Custom_Icon__c,
                            Description__c,
                            Icons_package__c,
                            Name,
                            Label__c
                    FROM Icon_Details__c
                    WHERE Visit_Plan__c = :planId
            ];

            wrapper.visits = [
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

            return JSON.serialize(wrapper);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static void cloneVisitPlan(String planId) {
        try {
            Visit_Plan__c plan = [SELECT Id FROM Visit_Plan__c WHERE Id = :planId];

            List<Visit__c> visits = [
                    SELECT
                            Icons__c,
                            Name,
                            Order__c,
                            Patient_Portal_Name__c,
                            Visit_Number__c,
                            Visit_Schedule__c
                    FROM Visit__c
                    WHERE Visit_Plan__c = :plan.Id
            ];

            List<Icon_Details__c> iconDetails = [
                    SELECT
                            Custom_Icon__c,
                            Description__c,
                            Icons_package__c,
                            Name,
                            Label__c
                    FROM Icon_Details__c
                    WHERE Visit_Plan__c = :plan.Id
            ];

            Visit_Plan__c clonePlan = plan.clone();
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
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String updateVisit(String planId, String visitRec, String mode) {
        try {
            Visit__c visit = (Visit__c) JSON.deserialize(visitRec, Visit__c.class);
            if(visit.Id == null) {
                insert visit;
            } else {
                if (mode.equals('edit')) {
                    update visit;
                } else if (mode.equals('delete')) {
                    delete visit;
                }
            }

            return getVisitPlanWrapper(planId);
        } catch (Exception e) {
            return (String) AuraHelper.throwException(e);
        }
    }
}