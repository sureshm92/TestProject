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
        public String selectedSSIds;
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
            if (initData.vendorItems.isEmpty()) {
                return new InitData();
            }
            Set<String> uniqueCC = new Set<String>();
            Set<Id> vendorIds = new Set<Id>();
            Set<Id> manualSsIds = new Set<Id>();
            for (VendorItem item : initData.vendorItems) {
                if (!item.studySite.TravelVendorSettings__r.isEmpty()) {
                    Boolean isManual = false;
                    for (TravelVendorSettings__c travelVendorSettings : item.studySite.TravelVendorSettings__r) {
                        vendorIds.add(travelVendorSettings.TravelVendor__c);
                        if (travelVendorSettings.Is_Manual__c) {
                            manualSsIds.add(travelVendorSettings.Study_Site__c);
                            isManual = true;
                        }
                    }
                    if (!isManual) {
                        String countryName = item.studySite.Site__r.BillingCountry;
                        String countryCode = item.studySite.Site__r.BillingCountryCode;
                        if ((countryCode != null && countryName != null) && !uniqueCC.contains(countryCode)) {
                            uniqueCC.add(countryCode);
                            initData.countryCodes += countryCode + ';';
                        }
                    }

                }
            }
            if (vendorIds.isEmpty()) {
                return new InitData();
            }
            if (!manualSsIds.isEmpty()) {
                initData.selectedSSIds = String.join(new List<Id>(manualSsIds), ';');
            }
            initData.countryCodes = initData.countryCodes.removeEnd(';');
            List<TravelVendor__c> travelVendors = supportHelper.getTravelVendorsByIds(new List<Id>(vendorIds));
            initData.vendors = travelVendors;
            supportHelper.fillVendorSettingsWithStub(travelVendors, initData.vendorItems);
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
        return initData;
    }

    @AuraEnabled
    public static List<VendorItem> getFilteredItems(Id ctpId, String ssIds, String countryCodes, List<TravelVendor__c> vendors) {
        List<VendorItem> result = new List<VendorItem>();
        TravelSupportHelper supportHelper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        Boolean isCountryCodes = countryCodes != null && String.isNotBlank(countryCodes);
        Boolean isStudySiteIds = ssIds != null && String.isNotBlank(ssIds);
        Boolean isVendors = vendors != null && !vendors.isEmpty();
        if (!isCountryCodes && !isStudySiteIds) {
            return result;
        }
        try {
            List<String> countryCodeList;
            if (isCountryCodes) {
                countryCodeList = countryCodes.split(';');
            }
            List<String> studyIds;
            if (isStudySiteIds) {
                studyIds = ssIds.split(';');
            }
            result = supportHelper.getVendorItems(countryCodeList, ctpId, studyIds, vendors);
            if (isVendors) {
                supportHelper.fillVendorSettingsWithStub(vendors, result);
            }
        } catch (Exception e) {
            return (List<VendorItem>) AuraHelper.throwException(e);
        }
        return result;
    }

    @AuraEnabled
    public static void saveData(Id ctpId, List<TravelVendorSettings__c> settings) {
        TravelSupportHelper supportHelper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        List<TravelVendorSettings__c> travelVendorSettings = new List<TravelVendorSettings__c>();
        Set<Id> travelVendorSettingsIds = new Set<Id>();
        try {
            if (settings != null && !settings.isEmpty()) {
                for (TravelVendorSettings__c vendorSetting : settings) {
                    if (vendorSetting.isEnable__c) {
                        travelVendorSettings.add(vendorSetting);
                        if (vendorSetting.Id != null) {
                            travelVendorSettingsIds.add(vendorSetting.Id);
                        }
                    }
                }
            }
            supportHelper.deleteTravelSettings(ctpId, travelVendorSettingsIds);
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
            if (newVendor != null) {
                insert newVendor;
            }
        } catch (Exception e) {
            return (TravelVendor__c) AuraHelper.throwException(e);
        }
        return newVendor;
    }

}