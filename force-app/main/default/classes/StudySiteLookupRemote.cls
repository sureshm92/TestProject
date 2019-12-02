/**
 * Created by Vitalii Aheienko on 9/24/2019.
 */

public class StudySiteLookupRemote {

    private static final String INCLUDE_ICON = 'standard:task2';
    private static final String EXCLUDE_ICON = 'standard:first_non_empty';

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSSByTerm(Id ctpId, String searchTerm, String value, String selectedCountries,Boolean includeSS) {
        try {
            List<String> selectedIds = new List<String>();
            if(!String.isEmpty(value)) selectedIds = value.split(';');
            String term = '%';
            if(searchTerm != null) term += (searchTerm + '%');

            String filter = 'Clinical_Trial_Profile__c = \'' + ctpId + '\''
                    + ' AND ' + DatabaseService.fieldNotInValues('Id', selectedIds);
            if (selectedCountries != null && !String.isEmpty(selectedCountries)) {
                filter += 'AND ' + DatabaseService.fieldInValues('Site__r.BillingCountryCode', selectedCountries.split(';'));
            }
            filter += 'AND (Study_Site_Number__c = \'' + searchTerm + '\' OR Name LIKE \'' + term + '\')' +
                    ' LIMIT 10';

            List<Study_Site__c> ssList = (List<Study_Site__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                    'Id',
                    'Name',
                    'Principal_Investigator__r.Name'
            }, Study_Site__c.getSObjectType(), filter);
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for(Study_Site__c ss : ssList){
                resList.add(new LookupSearchResult(
                        ss.Id,
                        'Study_Site__c',
                        includeSS ? INCLUDE_ICON : EXCLUDE_ICON,
                        ss.Name,
                        ss.Principal_Investigator__r.Name
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSSByIds(String value, String selectedCountries, Boolean includeSS){
        try{
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            String filter = DatabaseService.fieldInValues('Id', value.split(';'));
            if (selectedCountries != null && !String.isEmpty(selectedCountries)) {
                filter += 'AND ' + DatabaseService.fieldInValues('Site__r.BillingCountryCode', selectedCountries.split(';'));
            }
            List<Study_Site__c> ssList = (List<Study_Site__c>) DatabaseService.query(new List<String>{
                    'Id',
                    'Name'
            }, Study_Site__c.getSObjectType(), filter);
            for(Study_Site__c ss: ssList){
                resList.add(new LookupSearchResult(
                        ss.Id,
                        'Study_Site__c',
                        includeSS ? INCLUDE_ICON : EXCLUDE_ICON,
                        ss.Name,
                        null
                ));
            }
            return resList;
        }catch (Exception e){
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

}