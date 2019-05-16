/**
 * Created by Leonid Bartenev
 */

public class DatabaseService {
    
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
        String queryString = 'SELECT ' + String.join(fields, ',') + ' FROM ' + objectType;
        if(filter != null) queryString += ' WHERE ' + filter;
        return queryImpl(queryString);
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
    
    public static Database.SaveResult insertSObj(SObject sObj, Boolean allOrNothing){
        return getInstance().insertSObjImpl(sObj, allOrNothing);
    }
    public static String listToString(List<SObject> sObjects){
        Map<Id, SObject> sObjectMap = new Map<Id, SObject>(sObjects);
        List<Id> idsList = new List<Id>(sObjectMap.keySet());
        return '(\'' + String.join(idsList, '\',\'') + '\')';
    }
    
    public static String fieldEqual(String field, String value){
        return ' ' + field + ' = \'' + value + '\' ' ;
    }
    
    public static String fieldIn(String field, List<SObject> sObjects){
        return ' ' + field + ' IN ' + listToString(sObjects) + ' ' ;
    }
}