/**
 * Created by Igor Malyuta on 21.11.2019.
 */

public without sharing class VisitPlanSearchLookup {

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchVPByTerm(String searchTerm, String value) {
        try {
            List<String> selectedIds = new List<String>();
            if (!String.isEmpty(value)) selectedIds = value.split(';');
            String term = '%';
            if (searchTerm != null) term += (searchTerm + '%');

            String filter =
                    DatabaseService.fieldNotInValues('Id', selectedIds) +
                            'AND Name LIKE \'' + term + '\' LIMIT 10';

            List<Visit_Plan__c> visitPlans = (List<Visit_Plan__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                    'Id',
                    'Name'
            }, Visit_Plan__c.getSObjectType(), filter);
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (Visit_Plan__c vp : visitPlans) {
                resList.add(new LookupSearchResult(
                        vp.Id,
                        'Visit_Plan__c',
                        'standard:visits',
                        vp.Name,
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchVPByIds(String value) {
        try {
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            List<String> vpIds = value.split(';');

            String filter = DatabaseService.fieldInValues('Id', vpIds);

            List<Visit_Plan__c> visitPlans = (List<Visit_Plan__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                    'Id',
                    'Name'
            }, Visit_Plan__c.getSObjectType(), filter);
            for (Visit_Plan__c vp : visitPlans) {
                resList.add(new LookupSearchResult(
                        vp.Id,
                        'Visit_Plan__c',
                        'standard:visits',
                        vp.Name,
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }
}