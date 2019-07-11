/**
 * Created by dobro on 21.06.2019.021.
 */

public with sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(
            List<Icon_details__c> iconsDetails,
            String iconPackageId,
            String visitPlanId) {
        List<VisitPackage__c> packages = [
                SELECT Id
                FROM VisitPackage__c
                WHERE
                Icons_package__c = :iconPackageId AND Visit_Plan__c = :visitPlanId
        ];
        if (packages.isEmpty()) {
            VisitPackage__c visitPack = new VisitPackage__c();
            visitPack.Visit_Plan__c = visitPlanId;
            visitPack.Icons_package__c = iconPackageId;
            insert visitPack;
        }
        for (Icon_details__c d : iconsDetails) {
            d.Icons_package__c = iconPackageId;
        }
        upsert iconsDetails;
    }
    @AuraEnabled
    public static List<Icon_details__c> createVisitPackage(String iconPackageId, String visitPlanId) {
        try {
            List<Icon_Details__c> defaultIconsDetails = VisitIconsConfiguration.getDefaultIcons();
            VisitPackage__c visitPack = new VisitPackage__c();
            visitPack.Visit_Plan__c = visitPlanId;
            visitPack.Icons_package__c = iconPackageId;
            insert visitPack;
            return defaultIconsDetails;
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
    @AuraEnabled
    public static List<Icon_details__c> geCustomIcons(String visitPlanId) {
        return null;
    }
    @AuraEnabled
    public static List<Icon_details__c> getExistingLegend(String iconPackageId) {
        System.debug('Icons pack Id' + iconPackageId);
        List<Icon_Details__c> details = [
                SELECT Id
                        ,Name
                        ,Label__c
                        ,Description__c
                FROM Icon_Details__c
                WHERE Icons_package__c = :iconPackageId
        ];
        System.debug('details' + details);
        return VisitIconsConfiguration.getPopulateIconDetails(details);
    }
    @AuraEnabled
    public static List<Icon_Details__c> getThisLegend(String visitPlanId) {
        List<VisitPackage__c> visitPackages = [SELECT ID,Icons_package__c FROM VisitPackage__c WHERE Visit_Plan__c = :visitPlanId];
        if (visitPackages.isEmpty()) {
            return new List<Icon_Details__c>();
        } else {
            set<Id> iconsPackIds = new Set<Id>();
            for (VisitPackage__c p : visitPackages) {
                iconsPackIds.add(p.Icons_package__c);
            }
            List<Icon_Details__c> details = [
                    SELECT Id
                            ,Name
                            ,Label__c
                            ,Description__c
                    FROM Icon_Details__c
                    WHERE Icons_package__c In:iconsPackIds
            ];

            return VisitIconsConfiguration.getPopulateIconDetails(details);
        }

    }

}