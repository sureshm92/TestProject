/**
 * Created by Leonid Bartenev
 */

public class VisitResultSharingCountryLookupRemote {
    
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
            Boolean isInclude, String ctpId, String countries) {
        try {
            List<String> selectedCountries = new List<String>();
            if (String.isNotBlank(countries)) selectedCountries = countries.split(';');

            String icon = isInclude ? INCLUDE_ICON : EXCLUDE_ICON;

            List<String> selectedIds = new List<String>();
            if(!String.isEmpty(value)) selectedIds = value.split(';');
            if(searchTerm == null) searchTerm = '';
            Map<String, CountryStateWrapper> allCountryStatesMap = new Map<String, VisitResultSharingCountryLookupRemote.CountryStateWrapper>();
            for(LabelValueItem country : CountryStateUtil.getCountries()){
                List<LabelValueItem> states = CountryStateUtil.getStatesByCountryMap().get(country.value);
                allCountryStatesMap.put(country.label, new CountryStateWrapper(country, null));
                if(states != null && includeStates){
                    for(LabelValueItem state : states) allCountryStatesMap.put(country.label + ',' + state.label, new CountryStateWrapper(country, state));
                }
            }

            List<String> availableCountyStateCodes = getAvailableCountyStateCodes(ctpId, includeStates, selectedCountries);
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
    public static List<LookupSearchResult> searchResultsByValue(String value, Boolean isInclude, String countries){
        try{
            String icon = isInclude ? INCLUDE_ICON : EXCLUDE_ICON;

            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            if(String.isBlank(value)) return resList;
            List<String> items = value.split(';');
            List<String> globalCountries = String.isBlank(countries) ? new List<String>() : countries.split(';');
            for (String item : items) {
                List<String> countryState = item.split('-');
                String countryCode = countryState[0];
                if(!globalCountries.isEmpty() && !globalCountries.contains(countryCode)) continue;

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

    private static List<String> getAvailableCountyStateCodes(String ctpId, Boolean includeStates, List<String> selectedCountries) {

        List<String> fields = new List<String>{'Site__r.BillingCountryCode', 'Site__r.BillingState'};
        String filter = DatabaseService.fieldEqual('Clinical_Trial_Profile__c', ctpId) +
                (!selectedCountries.isEmpty() ? (' AND ' + DatabaseService.fieldInValues('Site__r.BillingCountryCode', selectedCountries)) : '');

        List<Study_Site__c> studySites = (List<Study_Site__c>)DatabaseService.query(fields, Study_Site__c.getSObjectType(), filter);

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