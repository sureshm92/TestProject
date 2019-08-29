/**
 * Created by Vitalii Aheienko on 8/29/2019.
 */

public with sharing class TravelVendorPanelRemote {

    public class InitData {
        @AuraEnabled public List<TravelVendor__c> vendors;
        @AuraEnabled public String countryCodes;
        @AuraEnabled public List<VendorItem> studySiteItems;
    }

    public class VendorItem {
        @AuraEnabled public Study_Site__c ss;
        @AuraEnabled public List<TravelVendorSettings__c> vendorSettings;
    }

    @AuraEnabled
    public InitData getInitData() {
        return null;
    }

    @AuraEnabled
    public static List<VendorItem> getFilteredItems(Id ctpId, List<Id> ssIds, List<String> countryCodes, List<TravelVendor__c> vendors) {
        return null;
    }

    @AuraEnabled
    public static void saveData(List<VendorItem> items) {

    }

    @AuraEnabled
    public static void createVendor(TravelVendor__c newVendor) {

    }

}