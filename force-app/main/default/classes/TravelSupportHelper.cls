/**
 * Created by Yehor Dobrovolskyi
 */
public without sharing class TravelSupportHelper {

    public List<TravelVendorPanelRemote.VendorItem> getVendorItems(List<String> countryCodes, Id ctpId,
            List<String> studySiteIds, List<TravelVendor__c> vendors) {
        DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
        String clauseChild = '';
                if (vendors != null && !vendors.isEmpty()) {
            Set<Id> venIds = new Map<Id, TravelVendor__c>(vendors).keySet();
            clauseChild = 'WHERE TravelVendor__c IN ' + '(\'' + String.join(new List<Id>(venIds), '\',\'') + '\')';
        }
        String query = 'SELECT Id, ' +
                'Name, ' +
                'Clinical_Trial_Profile__c, ' +
                'Site__r.BillingCountry, ' +
                'Site__r.BillingCountryCode, ' +
                '(SELECT Id, isEnable__c, TravelVendor__r.Name, TravelVendor__r.Default_Country__c, TravelVendor__r.Link_Vendor__c FROM TravelVendorSettings__r' + (String.isBlank(clauseChild) ? '' : clauseChild) + ') ' +
                'FROM Study_Site__c ';
        String clause = 'WHERE Clinical_Trial_Profile__c = \'' + ctpId + '\' ';
        if (countryCodes != null && !countryCodes.isEmpty()) {
            clause += ' AND Site__r.BillingCountryCode IN ' + '(\'' + String.join(countryCodes, '\',\'') + '\')';
        }
        if (studySiteIds != null && !studySiteIds.isEmpty()) {
            clause += ' AND Id IN ' + '(\'' + String.join(studySiteIds, '\',\'') + '\')';
        }
        String order = ' ORDER BY Name';
        query += clause;
        query += order;
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
                'Link_Vendor__c, ' +
                'FROM TravelVendor__c ';
        String clause = 'WHERE Id IN ' + '(\'' + String.join(travelVendorIds, '\',\'') + '\')';
        String order = ' ORDER BY Name';
        query += clause;
        query += order;
        List<TravelVendor__c> travelVendors = databaseProxy.query(query);
        return travelVendors;
    }


 /*   public List<LookupSearchResult> searchCountries(String searchTerm, String value, Boolean includeStates,
            Boolean isInclude, String ctpId) {
        String icon = isInclude ? INCLUDE_ICON : EXCLUDE_ICON;

        List<String> selectedIds = new List<String>();
        if (!String.isEmpty(value)) selectedIds = value.split(';');
        if (searchTerm == null) searchTerm = '';
        Map<String, CountryStateDTO> allCountryStatesMap = new Map<String, TravelSupportHelper.CountryStateDTO>();
        for (LabelValueItem country : CountryStateUtil.getCountries()) {
            List<LabelValueItem> states = CountryStateUtil.getStatesByCountryMap().get(country.value);
            allCountryStatesMap.put(country.label, new CountryStateDTO(country, null));
            if (states != null && includeStates) {
                for (LabelValueItem state : states) allCountryStatesMap.put(country.label + ',' + state.label, new CountryStateDTO(country, state));
            }
        }
        List<String> availableCountyStateCodes = getAvailableCountyStateCodes(ctpId, includeStates);
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        for (String label : allCountryStatesMap.keySet()) {
            CountryStateDTO countryStateWrapper = allCountryStatesMap.get(label);
            if (selectedIds.contains(countryStateWrapper.getKey())) continue;
            if (String.isBlank(searchTerm) || label.containsIgnoreCase(searchTerm) || countryStateWrapper.getKey().containsIgnoreCase(searchTerm)) {
                if (availableCountyStateCodes.contains(countryStateWrapper.getKey())) {
                    results.add(new LookupSearchResult(
                            countryStateWrapper.getKey(),
                            'Country',
                            icon,
                            countryStateWrapper.country.label,
                            countryStateWrapper.getStateLabel()
                    ));
                }
            }
            if (searchTerm.length() < 2 && results.size() >= 50) break;
        }
        return results;
    }

    public List<LookupSearchResult> searchCountryByValue(String value, Boolean isInclude) {
        String icon = isInclude ? INCLUDE_ICON : EXCLUDE_ICON;

        List<LookupSearchResult> resList = new List<LookupSearchResult>();
        if (String.isBlank(value)) return resList;
        List<String> items = value.split(';');
        for (String item : items) {
            List<String> countryState = item.split('-');
            String countryCode = countryState[0];
            String stateCode = 'XXXX';
            if (countryState.size() > 1) stateCode = countryState[1];
            String countryLabel = CountryStateUtil.getCountryName(countryCode);
            String stateLabel = CountryStateUtil.getStateName(countryCode, stateCode);
            resList.add(new LookupSearchResult(
                    item,
                    'Country',
                    icon,
                    countryLabel,
                    stateLabel
            ));
        }
        return resList;
    }

    private List<String> getAvailableCountyStateCodes(String ctpId, Boolean includeStates) {
        List<Study_Site__c> studySites = [
                SELECT
                        Site__r.BillingCountryCode,
                        Site__r.BillingState
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__c = :ctpId
        ];

        List<String> codes = new List<String>();
        for (Study_Site__c ss : studySites) {
            String code = ss.Site__r.BillingCountryCode;
            if (!codes.contains(code)) codes.add(code);
            if (includeStates) code += '-' + ss.Site__r.BillingState;
            codes.add(code);
        }

        return codes;
    }

    public TravelVendorDTO getVendorSettings(Id ctpId, List<String> countrys) {
        TravelVendorDTO vendorDTO = new TravelVendorDTO();

        VendorResultSelector vendorResultSelector = ((VendorResultSelector) ClassFactory.newInstance(VendorResultSelector.class));
        vendorDTO.travelVendorSettings = vendorResultSelector.getVendorSettings(ctpId);

        List<Study_Site__c> sites = vendorResultSelector.getStudySitesByCtpId(ctpId);
        Set<Id> ssIds = new Map<Id, Study_Site__c>(sites).keySet();
        vendorDTO.selectedSSIds = String.join(new List<Id>(ssIds), ';');
        return vendorDTO;
    }

    public List<TravelVendorSettings__c> getVendorSettings(Id ctpId, List<String> countrys, String selectedSSIds) {

        VendorResultSelector vendorResultSelector = ((VendorResultSelector) ClassFactory.newInstance(VendorResultSelector.class));

        return vendorResultSelector.getVendorSettingsByCountry(ctpId, countrys);
    }


    public List<TravelVendor__c> upsertVendor(List<TravelVendor__c> vendors) {
        upsert vendors;
        return vendors;
    }

    private class CountryStateDTO {

        LabelValueItem country;
        LabelValueItem state;

        public CountryStateDTO(LabelValueItem country, LabelValueItem state) {
            this.country = country;
            this.state = state;
        }

        public String getKey() {
            String key = country.value;
            if (state != null) key += '-' + state.value;
            return key;
        }

        public String getStateLabel() {
            if (state != null) return state.label;
            return '';
        }
    }

    public class TravelVendorDTO {
        @AuraEnabled
        public String selectedSSIds;
        @AuraEnabled
        public List<TravelVendorSettings__c> travelVendorSettings;

    }*/
}