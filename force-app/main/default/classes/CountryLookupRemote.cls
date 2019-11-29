/**
 * Created by Vitalii Aheienko on 9/24/2019.
 */

public with sharing class CountryLookupRemote {

    private final static List<String> DEFAULT_COUNTRIES = new List<String>{'US', 'CA'};
    private static final String INCLUDE_ICON = 'standard:task2';
    private static final String EXCLUDE_ICON = 'standard:first_non_empty';

    private class CountryStateWrapper{

        LabelValueItem country;
        LabelValueItem state;

        public CountryStateWrapper(LabelValueItem country, LabelValueItem state){
            this.country = country;
            this.state = state;
        }

        public String getKey(){
            String key = country.value;
            if(state != null) key += '-' + state.value;
            return key;
        }

        public String getStateLabel(){
            if(state != null) return state.label;
            return '';
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchCountries(String searchTerm, String value, Boolean includeStates,
            Boolean isInclude,String ctpId) {
        try {
            String icon = isInclude ? INCLUDE_ICON : EXCLUDE_ICON;

            List<String> selectedIds = new List<String>();
            if(!String.isEmpty(value)) selectedIds = value.split(';');
            if(searchTerm == null) searchTerm = '';
            Map<String, CountryStateWrapper> allCountryStatesMap = new Map<String, CountryLookupRemote.CountryStateWrapper>();
            for(LabelValueItem country : CountryStateUtil.getCountries()){
                List<LabelValueItem> states = CountryStateUtil.getStatesByCountryMap().get(country.value);
                allCountryStatesMap.put(country.label, new CountryStateWrapper(country, null));
                if(states != null && includeStates){
                    for(LabelValueItem state : states) allCountryStatesMap.put(country.label + ',' + state.label, new CountryStateWrapper(country, state));
                }
            }

            List<String> availableCountyStateCodes = getAvailableCountyStateCodes(ctpId, includeStates);
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            for (String label : allCountryStatesMap.keySet()) {
                CountryStateWrapper countryStateWrapper = allCountryStatesMap.get(label);
                if (selectedIds.contains(countryStateWrapper.getKey())) continue;
                if (String.isBlank(searchTerm) || label.containsIgnoreCase(searchTerm) || countryStateWrapper.getKey().containsIgnoreCase(searchTerm)) {
                    if(availableCountyStateCodes.contains(countryStateWrapper.getKey())){
                        results.add(new LookupSearchResult(
                                countryStateWrapper.getKey(),
                                'Country',
                                icon,
                                countryStateWrapper.country.label,
                                countryStateWrapper.getStateLabel()
                        ));
                    }
                }
                if(searchTerm.length() < 2 && results.size() >= 50) break;
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchResultsByValue(String value, Boolean isInclude){
        try{
            String icon = isInclude ? INCLUDE_ICON : EXCLUDE_ICON;

            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            if(String.isBlank(value)) return resList;
            List<String> items = value.split(';');
            for(String item : items){
                List<String> countryState = item.split('-');
                String countryCode = countryState[0];
                String stateCode = 'XXXX';
                if(countryState.size() > 1) stateCode = countryState[1];
                String  countryLabel = CountryStateUtil.getCountryName(countryCode);
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
        }catch (Exception e){
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    private static List<String> getAvailableCountyStateCodes(String ctpId, Boolean includeStates) {
        List<Study_Site__c> studySites = [
                SELECT
                        Site__r.BillingCountryCode,
                        Site__r.BillingState
                FROM Study_Site__c
                WHERE Clinical_Trial_Profile__c = :ctpId
        ];

        List<String> codes = new List<String>();
        for(Study_Site__c ss : studySites) {
            String code = ss.Site__r.BillingCountryCode;
            if(!codes.contains(code)) codes.add(code);
            if(includeStates) code += '-' + ss.Site__r.BillingState;
            codes.add(code);
        }

        return codes;
    }

}