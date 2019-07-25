/**
 * Created by AlexKetch on 6/18/2019.
 */

public with sharing class VisitConfigurationRemote {

    @AuraEnabled
    public static List<Visit__c> getRelatedPlannedVisits(String ctpId) {
        CTPSelector selector= (CTPSelector)ClassFactory.newInstance(CTPSelector.class);

        try {
            List<Clinical_Trial_Profile__c> ctps = selector.getCtpById(ctpId);
            if (String.isNotBlank(ctps[0].Visit_Plan__c)) {

                return selector.getVisitsByCtpId(ctps[0].Visit_Plan__c);

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
            Visit__c v = new Visit__c(Id = visitId);
            delete v;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }
}