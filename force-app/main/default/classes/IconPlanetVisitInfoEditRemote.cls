/**
 * Created by dobro on 21.06.2019.021.
 */

public with sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_details__c> iconsDetails) {
        update iconsDetails;
    }
    @AuraEnabled
    public static List<Icon_details__c> getIconsDescription(String visitPlanId) {
        List<Icons_package__c> iconPackage =   [SELECT Id From Icons_package__c Where Visit_plan__c = :visitPlanId];
        if (iconPackage.isEmpty()) {
            List<Icons_package__c> iconPackageDefault =   [SELECT Id From Icons_package__c Where Name = 'default'];
            if(iconPackageDefault.isEmpty()){
                Icons_package__c packageMew = new Icons_package__c();
                packageMew.Name = 'default';
                packageMew.Visit_Plan__c = visitPlanId;
                insert packageMew;
                return createDefaultIconDetails(packageMew.Id);
            }else {
                return [
                        SELECT Id
                                ,Name
                                ,description__c
                                ,Icons_package__c
                                ,label__c
                        FROM Icon_details__c
                        WHERE Icons_package__c =: iconPackageDefault[0].Id
                ];
            }
        }
        List<Icon_details__c> icondetails = [
                SELECT Id
                        ,Name
                        ,description__c
                        ,Icons_package__c
                        ,label__c
                FROM Icon_details__c
                WHERE Icons_package__c IN: [SELECT Id From Icons_package__c Where Visit_plan__c = :visitPlanId]
        ];
        if (!icondetails.isEmpty()) {
            return icondetails;
        }else {
            return createDefaultIconDetails(visitPlanId);
        }

    }
    private static List<Icon_details__c> createDefaultIconDetails( String ipackage) {
        try {
            List<PicklistEntry> picklistEntries = Visit__c.Icons__c.getDescribe().picklistValues;
            List<Icon_details__c> iconDetails = new List<Icon_details__c>();
            for (PicklistEntry entry : picklistEntries) {
                Icon_details__c det = new Icon_details__c();
                det.Name = entry.value;
                det.Icons_package__c=ipackage;
                iconDetails.add(det);
            }
            insert iconDetails;
            return iconDetails;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;

    }

}