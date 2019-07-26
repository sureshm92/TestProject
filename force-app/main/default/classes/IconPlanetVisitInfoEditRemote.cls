/**
 * Created by dobro on 21.06.2019.021.
 */

public inherited sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_Details__c> iconsDetails, String ctpId) {
        try {
            Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                    .query('SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id = \'' + ctpId + '\'', true)[0];
            if (ctp != null) {
                for (Icon_Details__c singleIconDetails : iconsDetails) {
                    singleIconDetails.Visit_Plan__c = ctp.Visit_Plan__c;
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
            Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                    .query('SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id = \'' + ctpId + '\'', true)[0];
            List<Icon_Details__c> iconDetails = selector.getIconDetailsByVisitPlanInCTP(ctp);
            if (iconDetails == null) {
                return new List<Icon_Details__c>();
            }
            return iconDetails;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}