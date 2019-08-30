/**
 * Created by dmytro.fedchyshyn on 28.08.2019.
 */

public without sharing class TravelSupportRemote {

    @AuraEnabled
    public static List<TravelVendor__c> getVendors() {
        try {
            return [SELECT Id, Name, Link_Vendor__c FROM TravelVendor__c];
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
        return null;
    }
}