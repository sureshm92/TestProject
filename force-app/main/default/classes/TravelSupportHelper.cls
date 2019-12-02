/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class TravelSupportHelper {

    public List<TravelVendorPanelRemote.VendorItem> getVendorItems(List<String> countryCodes, Id ctpId,
            List<String> studySiteIds, List<Id> vendorIds, Boolean isFirstLoad) {
        Boolean hasAnyAttributes = this.hasAnyAttributes( countryCodes,  studySiteIds,  vendorIds, isFirstLoad);
        if (hasAnyAttributes) {
            return getAllStudySites(ctpId);
        }
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String clauseChild = '';
        Boolean isVendors = vendorIds != null && !vendorIds.isEmpty();
        Boolean isCountryCodes = countryCodes != null && !countryCodes.isEmpty();
        Boolean isStudySiteIds = studySiteIds != null && !studySiteIds.isEmpty();
        if (isVendors) {
            clauseChild = ' WHERE TravelVendor__c IN ' + '(\'' + String.join(new List<Id>(vendorIds), '\',\'') + '\')';
        }
        String query = 'SELECT Id, ' +
                'Name, ' +
                'Clinical_Trial_Profile__c, ' +
                'Site__r.BillingCountry, ' +
                'Site__r.BillingCountryCode, ' +
                'Study_Site_Number__c, ' +
                '(SELECT Id, isEnable__c, By_Country__c, Is_Manual__c, TravelVendor__r.Name, TravelVendor__r.Default_Country__c, TravelVendor__r.Link_Vendor__c, Study_Site__c, Study_Site__r.Site__r.BillingCountryCode FROM TravelVendorSettings__r' + (String.isBlank(clauseChild) ? '' : clauseChild) + ') ' +
                'FROM Study_Site__c ';
        String clause = ' WHERE Clinical_Trial_Profile__c = \'' + ctpId + '\' ';
        if (isCountryCodes) {
            clause += ' AND ' + (isStudySiteIds ? '(' : '') + 'Site__r.BillingCountryCode IN ' + '(\'' + String.join(countryCodes, '\',\'') + '\')';
        }
        if (isStudySiteIds) {
            clause += ' AND Id IN ' + '(\'' + String.join(studySiteIds, '\',\'') + '\')' + (isCountryCodes ? ') ' : '');
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
                vendorItems.add(vendorItem);
            } else if (isCountryCodes || isStudySiteIds || isVendors) {
                vendorItems.add(vendorItem);
            }
        }
        return vendorItems;
    }

    public List<TravelVendorPanelRemote.VendorItem> getInitData(Id ctpId) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String clauseChild = '';
        String query = 'SELECT Id, ' +
                'Name, ' +
                'Clinical_Trial_Profile__c, ' +
                'Site__r.BillingCountry, ' +
                'Site__r.BillingCountryCode, ' +
                'Study_Site_Number__c, ' +
                '(SELECT Id, isEnable__c, By_Country__c, Is_Manual__c, TravelVendor__r.Name, TravelVendor__r.Default_Country__c, TravelVendor__r.Link_Vendor__c, Study_Site__c, Study_Site__r.Site__r.BillingCountryCode FROM TravelVendorSettings__r' + (String.isBlank(clauseChild) ? '' : clauseChild) + ') ' +
                'FROM Study_Site__c ';
        String clause = ' WHERE Clinical_Trial_Profile__c = \'' + ctpId + '\' ';
        String order = ' ORDER BY Name';
        query += clause;
        query += order;
        System.debug(query);
        List<Study_Site__c> studySites = databaseProxy.query(query);
        List<TravelVendorPanelRemote.VendorItem> vendorItems = new List<TravelVendorPanelRemote.VendorItem>();
        for (Study_Site__c studySite : studySites) {
            TravelVendorPanelRemote.VendorItem vendorItem = new TravelVendorPanelRemote.VendorItem(studySite);
            vendorItem.vendorSettings = studySite.TravelVendorSettings__r;
            vendorItems.add(vendorItem);
        }
        return vendorItems;
    }

    public void fillVendorSettingsWithStub(List<Id> travelVendorIds, List<TravelVendorPanelRemote.VendorItem> vendorItemsResult) {
        for (TravelVendorPanelRemote.VendorItem vendorItem : vendorItemsResult) {
            List<TravelVendorSettings__c> vendorSettingsWithStub = new List<TravelVendorSettings__c>();
            Map<Id, TravelVendorSettings__c> travelVendorSettingsByVendorId = new Map<Id, TravelVendorSettings__c>();
            for (TravelVendorSettings__c travelVendorSettings : vendorItem.vendorSettings) {
                travelVendorSettingsByVendorId.put(travelVendorSettings.TravelVendor__c, travelVendorSettings);
            }
            for (Id vendorId : travelVendorIds) {
                if (travelVendorSettingsByVendorId.containsKey(vendorId)) {
                    vendorSettingsWithStub.add(travelVendorSettingsByVendorId.get(vendorId));
                } else {
                    vendorSettingsWithStub.add(
                            new TravelVendorSettings__c (
                                    isEnable__c = false,
                                    TravelVendor__c = vendorId,
                                    Study_Site__c = vendorItem.studySite.Id,
                                    Study_Site__r = vendorItem.studySite
                            )
                    );
                }
            }
            vendorItem.vendorSettings = vendorSettingsWithStub;
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
    }

    public static List<TravelVendor__c> getVendors(String studySiteId) {
        String filter = 'Study_Site__c =  \'' + studySiteId + '\'' + ' ORDER BY TravelVendor__r.Name';
        List<TravelVendorSettings__c> vendorSettings =
                (List<TravelVendorSettings__c>) DatabaseService.query(new List<String>{
                        'TravelVendor__c',
                        'TravelVendor__r.Name',
                        'TravelVendor__r.Link_Vendor__c',
                        'TravelVendor__r.Disclosure__c'
                }, TravelVendorSettings__c.getSObjectType(), filter);

        Set<TravelVendor__c> vendorsUniq = new Set<TravelVendor__c>();
        for (TravelVendorSettings__c vendorSetting : vendorSettings) vendorsUniq.add(vendorSetting.TravelVendor__r);

        List<TravelVendor__c> vendors = new List<TravelVendor__c>();
        if(!vendorsUniq.isEmpty()) vendors.addAll(vendorsUniq);

        return vendors;
    }

    private List<TravelVendorPanelRemote.VendorItem> getAllStudySites(Id ctpId){
        String retrieveAllStudySites = 'SELECT Id, ' +
                'Name, ' +
                'Clinical_Trial_Profile__c, ' +
                'Site__r.BillingCountry, ' +
                'Site__r.BillingCountryCode, ' +
                'Study_Site_Number__c ' +
                'FROM Study_Site__c ' +
                'WHERE Clinical_Trial_Profile__c = \'' + ctpId + '\' ';
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        List<Study_Site__c> studySites = databaseProxy.query(retrieveAllStudySites);
        List<TravelVendorPanelRemote.VendorItem> vendorItems = new List<TravelVendorPanelRemote.VendorItem>();
        for (Study_Site__c studySite : studySites) {
            TravelVendorPanelRemote.VendorItem vendorItem = new TravelVendorPanelRemote.VendorItem(studySite);
            vendorItem.vendorSettings = studySite.TravelVendorSettings__r;
            vendorItems.add(vendorItem);
        }
        return vendorItems;
    }

    private Boolean hasAnyAttributes(List<String> countryCodes, List<String> studySiteIds, List<Id> vendorIds, Boolean isFirstLoad){
        return countryCodes == null && studySiteIds == null && (vendorIds == null || vendorIds.size() == 0) && !isFirstLoad;
    }

}