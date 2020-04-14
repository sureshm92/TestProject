/**
 * Created by Leonid Bartenev
 */

public without sharing class DatabaseService {

    public static final String SEPARATOR = '\',\'';

    private static DatabaseService instance;

    public static DatabaseService getInstance(){
        if(instance == null) instance = new DatabaseService();
        return instance;
    }

    public static void setMock(StubProvider stubProvider){
        instance = (DatabaseService) Test.createStub(DatabaseService.class, stubProvider);
    }

    public List<SObject> queryImpl(String query) {
        System.debug('QUERY: ' + query);
        return Database.query(query);
    }

    public List<SObject> queryImpl(List<String> fields, SObjectType objectType, String filter){
        return queryImpl(fields, objectType, filter, null, null, null);
    }

    public List<SObject> queryImpl(List<String> fields, SObjectType objectType, String filter, String orderBy){
        return queryImpl(fields, objectType, filter, orderBy, null, null);
    }

    public List<SObject> queryImpl(List<String> fields, SObjectType objectType, String filter, String orderBy, Integer limitNumber){
        return queryImpl(fields, objectType, filter, orderBy, limitNumber, null);
    }

    public List<SObject> queryImpl(List<String> fields, SObjectType objectType, String filter, String orderBy, Integer limitNumber, Integer offsetNumber){
        String queryString = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectType;
        if(filter != null) queryString += ' WHERE ' + filter;
        if(orderBy != null) queryString += ' ORDER BY ' + orderBy;
        if(limitNumber != null) queryString += ' LIMIT ' + limitNumber;
        if(offsetNumber != null) queryString += ' OFFSET ' + offsetNumber;
        return queryImpl(queryString);
    }

    public Integer countQueryImpl(String query) {
        System.debug('COUNT QUERY: ' + query);
        return Database.countQuery(query);
    }

    public Integer countQueryImpl(SObjectType objectType, String filter){
        String queryString = 'SELECT COUNT() FROM ' + objectType;
        if(filter != null) queryString += ' WHERE ' + filter;
        return countQueryImpl(queryString);
    }

    public Database.SaveResult insertSObjImpl(SObject sObj, Boolean allOrNothing){
        return Database.insert(sObj, allOrNothing);
    }

    public void upsertToDB(SObject sobj) {
        upsert sobj;
    }

    // Static facade: --------------------------------------------------------------------------------------------------

    public static List<SObject> query(String query) {
        return getInstance().queryImpl(query);
    }

    public static List<SObject> query(List<String> fields, SObjectType objectType, String filter){
        return getInstance().queryImpl(fields, objectType, filter);
    }

    public static List<SObject> query(List<String> fields, SObjectType objectType, String filter, String orderBy){
        return getInstance().queryImpl(fields, objectType, filter, orderBy);
    }

    public static List<SObject> query(List<String> fields, SObjectType objectType, String filter, String orderBy, Integer limitNumber){
        return getInstance().queryImpl(fields, objectType, filter, orderBy,limitNumber);
    }

    public static List<SObject> query(List<String> fields, SObjectType objectType, String filter, String orderBy, Integer limitNumber, Integer offsetNumber){
        return getInstance().queryImpl(fields, objectType, filter, orderBy, limitNumber, offsetNumber);
    }

    public static Integer countQuery(String query){
        return getInstance().countQueryImpl(query);
    }

    public static Integer countQuery(SObjectType objectType, String filter){
        return getInstance().countQueryImpl(objectType, filter);
    }

    public static Database.SaveResult insertSObj(SObject sObj, Boolean allOrNothing){
        return getInstance().insertSObjImpl(sObj, allOrNothing);
    }
    
    public static String listToString(List<SObject> sObjects){
        Map<Id, SObject> sObjectMap = new Map<Id, SObject>(sObjects);
        List<Id> idsList = new List<Id>(sObjectMap.keySet());
        return '(\'' + String.join(idsList, '\',\'') + '\')';
    }
    
    public static String listToString(List<String> values){
        return '(\'' + String.join(values, '\',\'') + '\')';
    }
    
    public static String fieldEqual(String field, String value){
        return ' ' + field + ' = \'' + value + '\' ' ;
    }
    public static String fieldNotEqual(String field, String value){
        return ' ' + field + ' != \'' + value + '\' ' ;
    }
    public static String fieldIn(String field, List<SObject> sObjects){
        return ' ' + field + ' IN ' + listToString(sObjects) + ' ' ;
    }
    public static String fieldNotIn(String field, List<SObject> sObjects){
        return ' ' + field + ' NOT IN ' + listToString(sObjects) + ' ' ;
    }
    public static String fieldInValues(String field, List<String> values){
        return ' ' + field + ' IN (\'' + String.join(values, SEPARATOR) + '\') ' ;
    }
    public static String fieldNotInValues(String field, List<String> values){
        return ' ' + field + ' NOT IN (\'' + String.join(values, SEPARATOR) + '\') ' ;
    }

    public static String fieldLike(String field, String value){
        return ' ' + field + ' LIKE \'%' + value + '%\' ' ;
    }
    public static String searchFields(List<String> searchFields, String searchText){
        String searchTextWithoutQuotes = String.escapeSingleQuotes(searchText);
        List<String> searchFilters = new List<String>();
        for(String field : searchFields){
            searchFilters.add(fieldLike(field, searchTextWithoutQuotes));
        }
        return ' ( ' + String.join(searchFilters,' OR ') + ' ) ' ;
    }
}