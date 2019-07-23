/**
 * Created by dobro on 21.06.2019.021.
 */

public with sharing class IconPlanetVisitInfoEditRemote {

    @AuraEnabled
    public static void saveIconInfo(List<Icon_details__c> iconsDetails) {
        upsert iconsDetails;
    }

    @AuraEnabled
    public static List<Icon_Details__c> getIconDetails(String visitPlanId) {

        List<Icon_Details__c> details = [
                SELECT Id
                        ,Name
                        ,Label__c
                        ,Description__c
                        ,Custom_Icon__c
                FROM Icon_Details__c
                WHERE
                        Visit_Plan__c = :visitPlanId
        ];
        return details;
    }

}