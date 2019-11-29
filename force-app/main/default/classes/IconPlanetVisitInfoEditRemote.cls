/**
 * Created by dobro on 21.06.2019.021.
 */

public inherited sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_Details__c> iconsDetails, String planId) {
        try {
            for (Icon_Details__c singleIconDetails : iconsDetails) singleIconDetails.Visit_Plan__c = planId;

            ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                    .upsertRecords(iconsDetails, true);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<Icon_Details__c> getIconDetails(String planId) {
        try {
            CTPSelector selector = (CTPSelector) ClassFactory.newInstance(CTPSelector.class);
            return selector.getIconDetailsByVisitPlanInCTP(planId);
        } catch (Exception e) {
            return (List<Icon_Details__c>) AuraHelper.throwException(e);
        }
    }
}