/**
 * Created by Leonid Bartenev
 */

public class VisitResultSharingSSLookupRemote {

    private static final String INCLUDE_ICON = 'standard:task2';
    private static final String EXCLUDE_ICON = 'standard:first_non_empty';
    
    @AuraEnabled(Cacheable = true)
    public static List<LookupSearchResult> searchSSByTerm(Id ctpId, String searchTerm, String value, Boolean includeSS) {
        try {
            List<String> selectedIds = new List<String>();
            if(!String.isEmpty(value)) selectedIds = value.split(';');
            String term = '%';
            if(searchTerm != null) term += (searchTerm + '%');
            List<Study_Site__c> ssList = [
                    SELECT Name, Principal_Investigator__r.Name
                    FROM Study_Site__c
                    WHERE Name LIKE: term
                    AND Clinical_Trial_Profile__c =: ctpId AND Id NOT IN: selectedIds
            ];
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
    public static List<LookupSearchResult> searchSSByIds(String value, Boolean includeSS){
        try{
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            List<String> ssIds = value.split(';');
            List<Study_Site__c> ssList = [SELECT Name FROM Study_Site__c WHERE Id IN: ssIds];
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