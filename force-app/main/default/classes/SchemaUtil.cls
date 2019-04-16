/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class SchemaUtil {

    public static String getRecordTypeById(String recordTypeId,Schema.SObjectType objectType) {
        return objectType
                .getDescribe()
                .getRecordTypeInfosById()
                .get(recordTypeId)
                .getName();
    }
    public static String getRecordTypeIdByName(String recordTypeName,Schema.SObjectType objectType) {
        return objectType
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get(recordTypeName)
                .getRecordTypeId();
    }
    public static String getRecordTypeBySobjectId(String recordId) {
        SObjectType sobjectType = Id.valueOf(recordId).getSobjectType();
        String sobjectApiName = sobjectType.getDescribe().getName();
        String query = 'Select RecordTypeId From ' + sobjectApiName +' where Id=:recordId';
        List<SObject> sobjets = Database.query(query);
        if(!sobjets.isEmpty()){
            return getRecordTypeById((String)sobjets[0].get('RecordTypeId'),sobjectType);
        }
        return null;

    }

}