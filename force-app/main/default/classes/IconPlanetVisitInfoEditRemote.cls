/**
 * Created by dobro on 21.06.2019.021.
 */

public with sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<icons_detail__c> iconsDetails) {
        update iconsDetails;
    }
    @AuraEnabled 
    public static List<icons_detail__c> getIconsDescription(String visitPlanId) {
        List<icons_detail__c> icondetails = [
                SELECT Id
                        ,Name
                        ,description__c
                        ,Icons_package__c
                        ,label__c
                FROM icons_detail__c
                WHERE Icons_package__c IN: [SELECT Id From Icons_package__c Where Visit_plan__c = :visitPlanId]
        ];
        return icondetails;
    }

}