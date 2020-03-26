/**
 * Created by Leonid Bartenev
 */

public class VisitResultSharingSSLookupRemote {

    private static final String INCLUDE_ICON = 'standard:task2';
    private static final String EXCLUDE_ICON = 'standard:first_non_empty';

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSSByTerm(Id ctpId, String searchTerm, String value, Boolean includeSS, String countries) {
        try {
            List<String> selectedCountries = new List<String>();
            if (String.isNotBlank(countries)) selectedCountries = countries.split(';');

            List<String> selectedIds = new List<String>();
            if (!String.isEmpty(value)) selectedIds = value.split(';');
            String term = '%';
            if (searchTerm != null) term += (searchTerm + '%');
            String filter = DatabaseService.fieldLike('Name', term) +
                    ' AND ' + DatabaseService.fieldNotInValues('Id', selectedIds) +
                    ' AND ' + DatabaseService.fieldEqual('Clinical_Trial_Profile__c', ctpId) +
                    (!selectedCountries.isEmpty() ? (' AND ' + DatabaseService.fieldInValues('Site__r.BillingCountryCode', selectedCountries)) : '');
            List<String> fields = new List<String>{
                    'Name', 'Principal_Investigator__r.Name'
            };
            List<Study_Site__c> ssList = (List<Study_Site__c>)DatabaseService.query(fields, Study_Site__c.getSObjectType(), filter);

            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (Study_Site__c ss : ssList) {
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
    public static List<LookupSearchResult> searchSSByIds(String value, Boolean includeSS, String countries) {
        try {
            List<String> selectedCountries = new List<String>();
            if (String.isNotEmpty(countries)) selectedCountries = countries.split(';');

            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            List<String> ssIds = value.split(';');

            String filter = DatabaseService.fieldInValues('Id', ssIds) +
                    (!selectedCountries.isEmpty() ? (' AND ' + DatabaseService.fieldInValues('Site__r.BillingCountryCode', selectedCountries)) : '');
            List<String> fields = new List<String>{'Name'};
            List<Study_Site__c> ssList = (List<Study_Site__c>)DatabaseService.query(fields, Study_Site__c.getSObjectType(), filter);

            for (Study_Site__c ss : ssList) {
                resList.add(new LookupSearchResult(
                        ss.Id,
                        'Study_Site__c',
                        includeSS ? INCLUDE_ICON : EXCLUDE_ICON,
                        ss.Name,
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

}