/**
 * Created by Vitalii Aheienko on 8/29/2019.
 */

public with sharing class TravelVendorPanelRemote {

    public static final String FEATURE_TRAVEL_VENDOR = 'Travel_Vendors';

    public class InitData {
        @AuraEnabled
        public List<TravelVendor__c> vendors;
        @AuraEnabled
        public String countryCodes;
        @AuraEnabled
        public String selectedSSIds;
        @AuraEnabled
        public List<VendorItem> vendorItems;
        @AuraEnabled
        public String permission;

        public InitData() {
            vendors = new List<TravelVendor__c>();
            vendorItems = new List<VendorItem>();
            countryCodes = '';
            selectedSSIds = '';
            permission = GetPermissions.getViewMode(FEATURE_TRAVEL_VENDOR);
        }
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
    public static InitData getAllData(Id ctpId) {
        TravelSupportHelper supportHelper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        InitData initData = new InitData();
        try {
            initData.vendorItems = supportHelper.getInitData(ctpId);
            Set<TravelVendor__c> vendorIds = new Set<TravelVendor__c>();
            for (VendorItem item : initData.vendorItems) {
                if (!item.studySite.TravelVendorSettings__r.isEmpty()) {
                    for (TravelVendorSettings__c travelVendorSettings : item.studySite.TravelVendorSettings__r) {
                        vendorIds.add(travelVendorSettings.TravelVendor__r);
                    }
                }
            }
            if (vendorIds != null) {
                List<TravelVendor__c> vendorsList = new List<TravelVendor__c>(vendorIds);
                vendorsList.sort();
                initData.vendors = vendorsList;
                List<Id> vendorIdsList = new List<Id>();
                for (TravelVendor__c travelVendor : vendorsList) {
                    vendorIdsList.add(travelVendor.Id);
                }
                supportHelper.fillVendorSettingsWithStub(vendorIdsList, initData.vendorItems);
            }
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
        return initData;
    }

    @AuraEnabled
    public static InitData getInitData(Id ctpId, Boolean isFirstLoad) {
        TravelSupportHelper supportHelper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        InitData initData;
        try {
            initData = new InitData();
            initData.countryCodes = '';
            initData.vendorItems = supportHelper.getVendorItems(null, ctpId, null, null, isFirstLoad);
            if (initData.vendorItems.isEmpty()) {
                return new InitData();
            }
            Set<String> uniqueCC = new Set<String>();
            Set<TravelVendor__c> vendorIds = new Set<TravelVendor__c>();
            Set<Id> manualSsIds = new Set<Id>();
            for (VendorItem item : initData.vendorItems) {
                if (!item.studySite.TravelVendorSettings__r.isEmpty()) {
                    Boolean isManual = false;
                    for (TravelVendorSettings__c travelVendorSettings : item.studySite.TravelVendorSettings__r) {
                        vendorIds.add(travelVendorSettings.TravelVendor__r);
                        if (travelVendorSettings.Is_Manual__c) {
                            manualSsIds.add(travelVendorSettings.Study_Site__c);
                            isManual = true;
                        }
                        if (travelVendorSettings.By_Country__c) {
                            String countryName = item.studySite.Site__r.BillingCountry;
                            String countryCode = item.studySite.Site__r.BillingCountryCode;
                            if ((countryCode != null && countryName != null) && !uniqueCC.contains(countryCode)) {
                                uniqueCC.add(countryCode);
                                initData.countryCodes += countryCode + ';';
                            }
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
            List<TravelVendor__c> vendorsList = new List<TravelVendor__c>(vendorIds);
            vendorsList.sort();
            initData.vendors = vendorsList;
            List<Id> vendorIdsList = new List<Id>();
            for (TravelVendor__c travelVendor : vendorsList) {
                vendorIdsList.add(travelVendor.Id);
            }
            supportHelper.fillVendorSettingsWithStub(vendorIdsList, initData.vendorItems);
            initData.vendorItems = getFilteredItems(ctpId, initData.selectedSSIds, initData.countryCodes, vendorIdsList, true);
        } catch (Exception e) {
            return (InitData) AuraHelper.throwException(e);
        }
        return initData;
    }

    @AuraEnabled
    public static List<VendorItem> getFilteredItems(Id ctpId, String ssIds, String countryCodes, List<Id> vendorIds, Boolean isFirstLoad) {
        List<VendorItem> result = new List<VendorItem>();
        TravelSupportHelper supportHelper = (TravelSupportHelper) ClassFactory.newInstance(TravelSupportHelper.class);
        Boolean isCountryCodes = String.isNotBlank(countryCodes);
        Boolean isStudySiteIds = String.isNotBlank(ssIds);
        try {
            List<String> countryCodeList;
            if (isCountryCodes) {
                countryCodeList = countryCodes.split(';');
            }
            List<String> studyIds;
            if (isStudySiteIds) {
                studyIds = ssIds.split(';');
            }
            result = supportHelper.getVendorItems(countryCodeList, ctpId, studyIds, vendorIds, isFirstLoad);
            supportHelper.fillVendorSettingsWithStub(vendorIds, result);
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
                    travelVendorSettings.add(vendorSetting);
                    if (vendorSetting.Id != null) {
                        travelVendorSettingsIds.add(vendorSetting.Id);
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