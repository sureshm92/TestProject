/**
 * Created by Leonid Bartenev
 */

public class VisitResultSharingCountryLookupRemote {
    
    private final static List<String> DEFAULT_COUNTRIES = new List<String>{'US', 'CA'};
    
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
    public static List<LookupSearchResult> searchCountries(String searchTerm, String value, Boolean includeStates) {
        try {
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
            
            List<LookupSearchResult> results = new List<LookupSearchResult>();
            for (String label : allCountryStatesMap.keySet()) {
                CountryStateWrapper countryStateWrapper = allCountryStatesMap.get(label);
                if (selectedIds.contains(countryStateWrapper.getKey())) continue;
                if (String.isBlank(searchTerm) ||label.containsIgnoreCase(searchTerm) || countryStateWrapper.getKey().containsIgnoreCase(searchTerm)
                        /*&& !selectedIds.contains(countryStateWrapper.country.value)*/) {
                    if((searchTerm.length() < 2 && DEFAULT_COUNTRIES.contains(countryStateWrapper.country.value) && countryStateWrapper.state == null) ||
                            searchTerm.length() >= 2){
                        results.add(new LookupSearchResult(
                                countryStateWrapper.getKey(),
                                'Country',
                                'custom:custom68',
                                countryStateWrapper.country.label,
                                countryStateWrapper.getStateLabel()
                        ));
                    }
                }
                if(searchTerm.length() < 2)
                if (results.size() >= 50) break;
            }
            return results;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchResultsByValue(String value){
        try{
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
                        'custom:custom68',
                        countryLabel,
                        stateLabel
                ));
            }
            return resList;
        }catch (Exception e){
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

}