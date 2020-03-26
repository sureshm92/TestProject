/**
 * Created by Igor Malyuta on 21.11.2019.
 */

public without sharing class StudySiteSearchLookup {

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSSByTerm(Id ctpId, String searchTerm, String value, String selectedCountries) {
        try {
            List<String> selectedIds = new List<String>();
            if (!String.isEmpty(value)) selectedIds = value.split(';');
            String term = '%';
            if (searchTerm != null) term += (searchTerm + '%');

            String filter = 'Clinical_Trial_Profile__c = \'' + ctpId + '\''
                    + ' AND ' + DatabaseService.fieldNotInValues('Id', selectedIds);
            if (selectedCountries != null && !String.isEmpty(selectedCountries)) {
                filter += 'AND ' + DatabaseService.fieldInValues('Site__r.BillingCountryCode', selectedCountries.split(';'));
            }
            filter += 'AND (Study_Site_Number__c = \'' + searchTerm + '\' OR Name LIKE \'' + term + '\')' +
                    ' LIMIT 10';

            List<Study_Site__c> studySites = (List<Study_Site__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                    'Id',
                    'Name'
            }, Study_Site__c.getSObjectType(), filter);
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (Study_Site__c ss : studySites) {
                resList.add(new LookupSearchResult(
                        ss.Id,
                        'Study_Site__c',
                        'standard:task2',
                        ss.Name,
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSSByIds(String value) {
        try {
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            List<String> ssIds = value.split(';');

            String filter = DatabaseService.fieldInValues('Id', ssIds);

            List<Study_Site__c> studySites = (List<Study_Site__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                    'Id',
                    'Name'
            }, Study_Site__c.getSObjectType(), filter);
            for (Study_Site__c ss : studySites) {
                resList.add(new LookupSearchResult(
                        ss.Id,
                        'Study_Site__c',
                        'standard:task2',
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