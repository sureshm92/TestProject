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
            return createDefaultIconDetails();
        }

    }
    private static List<Icon_details__c> createDefaultIconDetails() {
        try {
            List<PicklistEntry> picklistEntries = Visit__c.Icons__c.getDescribe().picklistValues;
            List<Icon_details__c> iconDetails = new List<Icon_details__c>();
            for (PicklistEntry entry : picklistEntries) {
                Icon_details__c det = new Icon_details__c();
                det.Name = entry.value;
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