/**
 * Created by Alexey Moseev on 5/7/20.
 */

public without sharing class IncentivePlanSearchLookup {

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchIPByTerm(String searchTerm, String value, String ctpId) {
        try {
            List<String> selectedIds = new List<String>();
            if (!String.isEmpty(value)) selectedIds = value.split(';');
            String term = '%';
            if (searchTerm != null) term += (searchTerm + '%');

            String filter =
                    DatabaseService.fieldNotInValues('Id', selectedIds) +
                            'AND (Name LIKE \'' + term + '\' OR Plan_Name__c LIKE \'' + term + '\') AND Clinical_Trial_Profile__c = \'' + ctpId + '\' LIMIT 10';

            List<Incentive_Plan__c> incentivePlans = (List<Incentive_Plan__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                    'Id',
                    'Name',
                    'Plan_Name__c'
            }, Incentive_Plan__c.getSObjectType(), filter);
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (Incentive_Plan__c ip : incentivePlans) {
                resList.add(new LookupSearchResult(
                        ip.Id,
                        'Incentive_Plan__c',
                        'standard:visits',
                        ip.Plan_Name__c,
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchIPByIds(String value, String ctpId) {
        try {
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            List<String> vpIds = value.split(';');

            String filter = DatabaseService.fieldInValues('Id', vpIds) + ' AND ' + DatabaseService.fieldEqual('Clinical_Trial_Profile__c', ctpId);

            List<Incentive_Plan__c> incentivePlans = (List<Incentive_Plan__c>) DatabaseService.getInstance().queryImpl(new List<String>{
                    'Id',
                    'Name',
                    'Plan_Name__c'
            }, Incentive_Plan__c.getSObjectType(), filter);
            for (Incentive_Plan__c ip : incentivePlans) {
                resList.add(new LookupSearchResult(
                        ip.Id,
                        'Incentive_Plan__c',
                        'standard:visits',
                        ip.Plan_Name__c,
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }
}