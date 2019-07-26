/**
 * Created by dobro on 21.06.2019.021.
 */

public inherited sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_Details__c> iconsDetails, String ctpId) {

        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                .query('SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id = \'' + ctpId + '\'', true)[0];

        if(ctp != null) {
            for(Icon_Details__c singleIconDetails : iconsDetails) {
                singleIconDetails.Visit_Plan__c = ctp.Visit_Plan__c;
            }
            upsert iconsDetails;
        }
    }

    @AuraEnabled
    public static List<Icon_Details__c> getIconDetails(String ctpId) {

        Clinical_Trial_Profile__c ctp = (Clinical_Trial_Profile__c) ((DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class))
                .query('SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id = \'' + ctpId + '\'', true)[0];
        if(ctp == null) {
            return new List<Icon_Details__c>();
        }
        List<Icon_Details__c> details = [
                SELECT Id
                        ,Name
                        ,Label__c
                        ,Description__c
                        ,Custom_Icon__c
                FROM Icon_Details__c
                WHERE
                        Visit_Plan__c = :ctp.Visit_Plan__c
        ];
        return details;
    }
}