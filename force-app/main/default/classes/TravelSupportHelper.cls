/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class TravelSupportHelper {

    public List<TravelVendorPanelRemote.VendorItem> getVendorItems(List<String> countryCodes, Id ctpId,
            List<String> studySiteIds, List<TravelVendor__c> vendors) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String clauseChild = '';
        Boolean isVendors = vendors != null && !vendors.isEmpty();
        Boolean isCountryCodes = countryCodes != null && !countryCodes.isEmpty();
        Boolean isStudySiteIds = studySiteIds != null && !studySiteIds.isEmpty();
        if (isVendors) {
            Set<Id> venIds = new Map<Id, TravelVendor__c>(vendors).keySet();
            clauseChild = ' WHERE TravelVendor__c IN ' + '(\'' + String.join(new List<Id>(venIds), '\',\'') + '\')';
        }
        String query = 'SELECT Id, ' +
                'Name, ' +
                'Clinical_Trial_Profile__c, ' +
                'Site__r.BillingCountry, ' +
                'Site__r.BillingCountryCode, ' +
                'Study_Site_Number__c, ' +
                '(SELECT Id, isEnable__c, TravelVendor__r.Name, TravelVendor__r.Default_Country__c, TravelVendor__r.Link_Vendor__c FROM TravelVendorSettings__r' + (String.isBlank(clauseChild) ? '' : clauseChild) + ') ' +
                'FROM Study_Site__c ';
        String clause = ' WHERE Clinical_Trial_Profile__c = \'' + ctpId + '\' ';
        if (isCountryCodes) {
            clause += ' AND ' + (isStudySiteIds ? '(' : '') + 'Site__r.BillingCountryCode IN ' + '(\'' + String.join(countryCodes, '\',\'') + '\')';
        }
        if (isStudySiteIds) {
            clause += (isCountryCodes ? ' OR' : ' AND') + ' Id IN ' + '(\'' + String.join(studySiteIds, '\',\'') + '\')' + (isCountryCodes ? ') ' : '');
        }
        String order = ' ORDER BY Name';
        query += clause;
        query += order;
        System.debug(query);
        List<Study_Site__c> studySites = databaseProxy.query(query);
        List<TravelVendorPanelRemote.VendorItem> vendorItems = new List<TravelVendorPanelRemote.VendorItem>();
        for (Study_Site__c studySite : studySites) {
            TravelVendorPanelRemote.VendorItem vendorItem = new TravelVendorPanelRemote.VendorItem(studySite);
            if (studySite.TravelVendorSettings__r != null && !studySite.TravelVendorSettings__r.isEmpty()) {
                vendorItem.vendorSettings = studySite.TravelVendorSettings__r;
            }

            vendorItems.add(vendorItem);
        }
        return vendorItems;
    }

    public List<TravelVendor__c> getTravelVendorsByIds(List<Id> travelVendorIds) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String query = 'SELECT Id, ' +
                'Name, ' +
                'Link_Vendor__c ' +
                'FROM TravelVendor__c ';
        String clause = 'WHERE Id IN ' + '(\'' + String.join(travelVendorIds, '\',\'') + '\')';
        String order = ' ORDER BY Name';
        query += clause;
        query += order;
        List<TravelVendor__c> travelVendors = databaseProxy.query(query);
        return travelVendors;
    }

    public void fillVendorSettingsWithStub(List<TravelVendor__c> travelVendors, List<TravelVendorPanelRemote.VendorItem> vendorItemsResult) {
        for (TravelVendor__c vendor : travelVendors) {
            for (TravelVendorPanelRemote.VendorItem vendorItem : vendorItemsResult) {
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
                                    TravelVendor__c = vendor.Id,
                                    TravelVendor__r = vendor,
                                    Study_Site__c = vendorItem.studySite.Id
                            )
                    );
                }
                vendorItem.vendorSettings = vendorSettingsWithStub;
            }
        }
    }

    public void deleteTravelSettings(Id ctpId, Set<Id> travelVendorSettingsIds) {
        String query = 'SELECT ' +
                'Id ' +
                'FROM TravelVendorSettings__c ' +
                'WHERE Study_Site__r.Clinical_Trial_Profile__c = \'' + ctpId + '\'' +
                (travelVendorSettingsIds.isEmpty() ? '' : ' AND Id NOT IN ' + '(\'' + String.join(new List<Id>(travelVendorSettingsIds), '\',\'') + '\')');
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<TravelVendorSettings__c> ts = (List<TravelVendorSettings__c>) databaseProxy.query(query);
        delete ts;
    }

}