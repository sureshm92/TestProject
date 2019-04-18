/**
 * Created by AlexKetch on 4/16/2019.
 */

public with sharing class SchemaUtil {

    public static Schema.RecordTypeInfo getRecordTypeInfoById(String recordTypeId, Schema.SObjectType sObjectType) {
        return sObjectType
                .getDescribe()
                .getRecordTypeInfosById()
                .get(recordTypeId);
    }

    public static String getRecordTypeNameById(String recordTypeId, Schema.SObjectType sObjectType) {
        return SchemaUtil.getRecordTypeInfoById(recordTypeId, sObjectType)
                .getName();
    }

    public static String getRecordTypeDeveloperNameById(String recordTypeId, Schema.SObjectType sObjectType) {
        return SchemaUtil.getRecordTypeInfoById(recordTypeId, sObjectType)
                .getDeveloperName();
    }

    public static String getRecordTypeIdByName(String recordTypeName, Schema.SObjectType objectType) {
        return objectType
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get(recordTypeName)
                .getRecordTypeId();
    }

    public static String getRecordTypeNameBySObjectId(String recordId) {

        RecordTypeInfo rTInfo = SchemaUtil.getRecordTypeInfoBySObjectId(recordId);
        if (rTInfo != null) {
            return rTInfo.getName();
        }
        return null;
    }

    public static String getRecordTypeDeveloperNameBySObjectId(String recordId) {

        RecordTypeInfo rTInfo = SchemaUtil.getRecordTypeInfoBySObjectId(recordId);
        if (rTInfo != null) {
            return rTInfo.getDeveloperName();
        }
        return null;
    }

    public static Schema.RecordTypeInfo getRecordTypeInfoBySObjectId(String recordId) {
        if (!String.isBlank(recordId)) {
            SObjectType sobjectType = Id.valueOf(recordId).getSobjectType();
            String sobjectApiName = sobjectType.getDescribe().getName();
            String query = 'SELECT RecordTypeId FROM ' + sobjectApiName + ' WHERE Id = \'' + recordId + '\'';
            DatabaseProxy databaseProxy = (DatabaseProxy) ClassFactory.newInstance(DatabaseProxy.class);
            List<SObject> sObjects = databaseProxy.query(query);
            if (!sObjects.isEmpty()) {
                return getRecordTypeInfoById((String) sObjects[0].get('RecordTypeId'), sobjectType);
            }
        }
        return null;
    }
}