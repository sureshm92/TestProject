/**
 * Created by dobro on 21.06.2019.021.
 */

public inherited sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_Details__c> iconsDetails, String ctpId) {
        CTPSelector selector = (CTPSelector) ClassFactory.newInstance(CTPSelector.class);

        List<Clinical_Trial_Profile__c> ctp = selector.getCtpById(ctpId);
        try {

            if (ctp != null) {
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
            if (ctpId != null) {
                List<Icon_Details__c> iconDetails = selector.getIconDetailsByVisitPlanInCTP(ctpId);
                if (iconDetails == null) {
                    return new List<Icon_Details__c>();
                }
                return iconDetails;
            } else {
                throw new AuraHandledException('CTP id is empty');
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}