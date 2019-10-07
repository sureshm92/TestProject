/**
 * Created by AlexKetch on 6/18/2019.
 */

public with sharing class VisitConfigurationRemote {

    @AuraEnabled
    public static List<Visit__c> getRelatedPlannedVisits(String ctpId) {
        CTPSelector selector= (CTPSelector)ClassFactory.newInstance(CTPSelector.class);

        try {
            List<Clinical_Trial_Profile__c> clinicalTrialProfiles = selector.getCtpById(ctpId);
            if (String.isNotBlank(clinicalTrialProfiles[0].Visit_Plan__c)) {

                return selector.getVisitsByCtpId(clinicalTrialProfiles[0].Visit_Plan__c);

            } else {
                return new List<Visit__c>();
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static List<Visit__c> updateCtp(String visitPlanId, String ctpId) {
        try {
            ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                    .updateRecord(new Clinical_Trial_Profile__c(Id = ctpId, Visit_Plan__c = visitPlanId), false);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }

    @AuraEnabled
    public static void deleteVisit(Id visitId) {
        try {
            Visit__c visit = new Visit__c(Id = visitId);
            ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                    .deleteRecord(visit, false);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}