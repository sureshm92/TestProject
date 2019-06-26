/**
 * Created by dobro on 21.06.2019.021.
 */

public with sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_Details__c> iconsDetails) {
        update iconsDetails;
    }
    @AuraEnabled
    public static List<Icon_Details__c> getIconsDescription(String visitPlanId) {
        List<Icon_Details__c> iconsDetails = [
                SELECT Id
                        ,Name
                        ,Description__c
                        ,Icons_package__c
                        ,Label__c
                FROM Icon_Details__c
                WHERE Icons_package__c IN: [SELECT Id FROM Icons_package__c WHERE Visit_Plan__c = :visitPlanId]
        ];
        return iconsDetails;
    }

}