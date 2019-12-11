/**
 * Created by Leonid Bartenev
 */

public without sharing class UISobjectLookupRemote {
    
    @AuraEnabled
    public static List<LookupSearchResult> searchSSByTerm(String sObjectType, String pillIcon, String filter, String searchTerm, String value) {
        try {
            List<String> selectedIds = new List<String>();
            if (!String.isEmpty(value)) selectedIds = value.split(';');
            String term = '%';
            if (searchTerm != null) term += (searchTerm + '%');
            String query = 'SELECT Id, Name FROM ' + sObjectType;
            query += ' WHERE Name LIKE \'' + term + '\'';
            if(!String.isEmpty(filter)) query += filter;
            if(selectedIds.size() > 0) query += ' AND ' + DatabaseService.fieldNotInValues('Id', selectedIds);
            query += 'LIMIT 10';
            List<SObject> items = DatabaseService.query(query);
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (SObject sObj : items) {
                resList.add(new LookupSearchResult(
                        sObj.Id,
                        sObjectType,
                        pillIcon,
                        sObj.get('Name') + '',
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static List<LookupSearchResult> searchSSByIds(String sObjectType, String pillIcon, String filter, String value) {
        try {
            List<String> selectedIds = new List<String>();
            if (!String.isEmpty(value)) selectedIds = value.split(';');
            String query = 'SELECT Id, Name FROM ' + sObjectType;
            query += ' WHERE ' + DatabaseService.fieldInValues('Id', selectedIds);
            if(!String.isEmpty(filter)) query += ' ' + filter;
            List<SObject> items = DatabaseService.query(query);
            List<LookupSearchResult> resList = new List<LookupSearchResult>();
            for (SObject sObj : items) {
                resList.add(new LookupSearchResult(
                        sObj.Id,
                        sObjectType,
                        pillIcon,
                        sObj.get('Name') + '',
                        null
                ));
            }
            return resList;
        } catch (Exception e) {
            return (List<LookupSearchResult>) AuraHelper.throwException(e);
        }
    }
}