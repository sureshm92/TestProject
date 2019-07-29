/**
 * Created by dobro on 21.06.2019.021.
 */

public inherited sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_Details__c> iconsDetails, String ctpId) {
        CTPSelector selector = (CTPSelector) ClassFactory.newInstance(CTPSelector.class);

        try {
            List<Clinical_Trial_Profile__c> ctp = selector.getCtpById(ctpId);
            if (!ctp.isEmpty()) {
                for (Icon_Details__c singleIconDetails : iconsDetails) {
                    singleIconDetails.Visit_Plan__c = ctp[0].Visit_Plan__c;
                }
                ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                        .upsertRecords(iconsDetails, true);
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static List<Icon_Details__c> getIconDetails(String ctpId) {
        CTPSelector selector = (CTPSelector) ClassFactory.newInstance(CTPSelector.class);

        try {
                return selector.getIconDetailsByVisitPlanInCTP(ctpId);
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}