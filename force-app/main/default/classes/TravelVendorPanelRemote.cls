/**
 * Created by Vitalii Aheienko on 8/29/2019.
 */

public with sharing class TravelVendorPanelRemote {

    public class InitData {
        @AuraEnabled
        public List<TravelVendor__c> vendors;
        @AuraEnabled
        public String countryCodes;
        @AuraEnabled
        public List<VendorItem> vendorItems;
    }

    public class VendorItem {
        @AuraEnabled
        public Study_Site__c studySite;
        @AuraEnabled
        public List<TravelVendorSettings__c> vendorSettings;

        public VendorItem(Study_Site__c ss) {
            this.studySite = ss;
            this.vendorSettings = new List<TravelVendorSettings__c>();
        }
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId) {
        TravelSupportHelper supportHelper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        InitData initData = new InitData();
        try {
            initData.countryCodes = '';
            initData.vendorItems = supportHelper.getVendorItems(null, ctpId, null, null);
            Set<String> uniqueCC = new Set<String>();
            Set<Id> vendorIds = new Set<Id>();
            for (VendorItem item : initData.vendorItems) {
                String countryName = item.studySite.Site__r.BillingCountry;
                String countryCode = item.studySite.Site__r.BillingCountryCode;
                if ((countryCode != null && countryName != null) && !uniqueCC.contains(countryCode)) {
                    uniqueCC.add(countryCode);
                    initData.countryCodes += countryCode + ';';
                }
                if (!item.studySite.TravelVendorSettings__r.isEmpty()) {
                    for (TravelVendorSettings__c travelVendorSettings : item.studySite.TravelVendorSettings__r) {
                        vendorIds.add(travelVendorSettings.TravelVendor__c);
                    }
                }
            }
            initData.countryCodes = initData.countryCodes.removeEnd(';');

            List<TravelVendor__c> travelVendors = supportHelper.getTravelVendorsByIds(new List<Id>(vendorIds));
            initData.vendors = travelVendors;
            for (TravelVendor__c vendor : travelVendors) {
                for (VendorItem vendorItem : initData.vendorItems) {
                    List<TravelVendorSettings__c> vendorSettingsWithStub = new List<TravelVendorSettings__c>();
                    Map<Id, TravelVendorSettings__c> travelVendorSettingsByVendorId = new Map<Id, TravelVendorSettings__c>();
                    for (TravelVendorSettings__c travelVendorSettings : vendorItem.vendorSettings) {
                        travelVendorSettingsByVendorId.put(travelVendorSettings.TravelVendor__c, travelVendorSettings);
                    }
                    if (travelVendorSettingsByVendorId.containsKey(vendor.Id)) {
                        vendorSettingsWithStub.add(travelVendorSettingsByVendorId.get(vendor.Id));
                    } else {
                        vendorSettingsWithStub.add(
                                new TravelVendorSettings__c (
                                        isEnable__c = false,
                                        TravelVendor__r = vendor
                                )
                        );
                    }
                    vendorItem.vendorSettings = vendorSettingsWithStub;
                }
            }
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
        return initData;
    }

    @AuraEnabled
    public static List<VendorItem> getFilteredItems(Id ctpId, String ssIds, String countryCodes, List<TravelVendor__c> vendors) {
        List<VendorItem> result = new List<VendorItem>();
        TravelSupportHelper supportHelper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        try {
            List<String> countryCodeList;
            if (countryCodes != null && String.isNotBlank(countryCodes)) {
                countryCodeList = countryCodes.split(';');
            }
            List<String> studyIds;
            if(ssIds != null && String.isNotBlank(ssIds)) {
                studyIds = ssIds.split(';');
            }
            result = supportHelper.getVendorItems(countryCodeList, ctpId, studyIds, vendors);
            for (TravelVendor__c vendor : vendors) {
                for (VendorItem vendorItem : result) {
                    List<TravelVendorSettings__c> vendorSettingsWithStub = new List<TravelVendorSettings__c>();
                    Map<Id, TravelVendorSettings__c> travelVendorSettingsByVendorId = new Map<Id, TravelVendorSettings__c>();
                    for (TravelVendorSettings__c travelVendorSettings : vendorItem.vendorSettings) {
                        travelVendorSettingsByVendorId.put(travelVendorSettings.TravelVendor__c, travelVendorSettings);
                    }
                    if (travelVendorSettingsByVendorId.containsKey(vendor.Id)) {
                        vendorSettingsWithStub.add(travelVendorSettingsByVendorId.get(vendor.Id));
                    } else {
                        vendorSettingsWithStub.add(
                                new TravelVendorSettings__c (
                                        isEnable__c = false,
                                        TravelVendor__r = vendor
                                )
                        );
                    }
                    vendorItem.vendorSettings = vendorSettingsWithStub;
                }
            }
        } catch (Exception e) {
            return (List<VendorItem>) AuraHelper.throwException(e);
        }
        return result;
    }

    @AuraEnabled
    public static void saveData(List<VendorItem> items) {
        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>();
        try {
            if (items != null && !items.isEmpty()) {
                for (VendorItem vendor : items) {
                    if (vendor.vendorSettings != null && !vendor.vendorSettings.isEmpty()) {
                        travelVendorSettings.addAll(vendor.vendorSettings);
                    }
                }
            }
            if (!travelVendorSettings.isEmpty()) {
                upsert travelVendorSettings;
            }
        } catch (Exception e) {
            AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static TravelVendor__c createVendor(TravelVendor__c newVendor) {
        try {
            insert newVendor;
        } catch (Exception e) {
            return (TravelVendor__c) AuraHelper.throwException(e);
        }
        return newVendor;
    }

}