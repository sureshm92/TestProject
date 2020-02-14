public with sharing class CollectionUtil {

    public class CollectionUtilException extends Exception {}

    public static final List<String> ALLOWED_FIELD_TYPES = new List<String>{
            'ID',
            'INTEGER',
            'PICKLIST',
            'REFERENCE',
            'STRING'
    };

    public static List<String> wrapInApostrophes(Set<Id> idsSet) {
        return CollectionUtil.wrapInApostrophes(CollectionUtil.getStringsSetFromIdsSet(idsSet));
    }

    public static List<String> wrapInApostrophes(List<String> valuesList) {
        return CollectionUtil.wrapInApostrophes(new Set<String>(valuesList));
    }

    public static List<String> wrapInApostrophes(Set<String> valuesSet) {

        List<String> result = new List<String>();
        for (String singleValue : valuesSet) {
            result.add('\'' + singleValue + '\'');
        }
        return result;
    }

    public static Set<String> getStringsSetFromIdsSet(Set<Id> idsSet) {
        Set<String> result = new Set<String>();
        for (Id singleId : idsSet) {
            result.add(singleId);
        }
        return result;
    }

    public static String joinByComa(List<String> listOfStrings) {
        return String.join(listOfStrings, ',');
    }
    public static List<String> split(String valueString, String separator) {
        return valueString.split(separator);
    }

    public static List<Id> getObjectIds(List<SObject> sObjects) {
        List<Id> ids = new List<Id>();
        for(SObject obj : sObjects) ids.add(obj.Id);

        return ids;
    }

    public static Map<String, SObject> getSObjectMap(List<SObject> sObjects, String keyField) {
        Schema.SObjectField field = (SObjectField) sObjects.get(0).getSObjectType().getDescribe().fields.getMap().get(keyField);
        Schema.DisplayType fieldType = field.getDescribe().getType();
        if(!ALLOWED_FIELD_TYPES.contains(String.valueOf(fieldType))) {
            throw new CollectionUtilException('Field type not supported as key');
        }

        Map<String, SObject> sObjectsMap = new Map<String, SObject>();
        for (SObject obj : sObjects) {
            sObjectsMap.put(obj.get(keyField).toString(), obj);
        }

        return sObjectsMap;
    }
}