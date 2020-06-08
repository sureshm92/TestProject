/**
 * Created by Leonid Bartenev
 */

public class SObjectHelper {
    
    //return parent sObject with all nested sObjects
    public static List<SObject> getAllSObjects(SObject sobj){
        List<SObject> sObjects = new List<SObject>();
        Map<String, Object> populatedFields = sobj.getPopulatedFieldsAsMap();
        for(String fieldName : populatedFields.keySet()){
            if(fieldName.endsWithIgnoreCase('__c') || fieldName.endsWithIgnoreCase('Id')) continue;
            try{
                SObject nestedSObj = sobj.getSObject(fieldName);
                sObjects.addAll(getAllSObjects(nestedSObj));
            }catch (Exception e){
            }
        }
        sObjects.add(sobj);
        return sObjects;
    }
    
    public static Object getSObjectFieldValue(SObject sObj, String fieldPath){
        List<String> pathItems = fieldPath.split('\\.');
        SObject currentSObject = sObj;
        for(Integer i = 0; i < pathItems.size() - 1; i++) {
            currentSObject = currentSObject.getSObject(pathItems[i]);
            if(currentSObject == null) return null;
        }
        return currentSObject.get(pathItems[pathItems.size() - 1]);
    }
    
    public static Boolean hasField(SObjectType sObjectType, String fieldPath){
        List<String> pathItems = fieldPath.split('\\.');
        for(String field : pathItems){
            field = field.replace('__r', '__c');
            SObjectField sObjectField = sObjectType.getDescribe().fields.getMap().get(field);
            if(sObjectField != null){
                if(sObjectField.getDescribe().getType() == DisplayType.REFERENCE){
                    List<SObjectType> soTypes = sObjectField.getDescribe().getReferenceTo();
                    if(soTypes.size() == 0) return false;
                    sObjectType = soTypes[0];
                }else {
                    break;
                }
            }else{
                return false;
            }
        }
        return true;
    }
    
    public static List<Id> toIdsList(List<SObject> sObjects){
        List<Id> resList = new List<Id>();
        for(SObject so : sObjects){
            resList.add((Id)so.get('Id'));
        }
        return resList;
    }
    
    public static List<LabelValueItem> getPicklistLabelValueList(SObjectField field){
        List<LabelValueItem> items = new List<LabelValueItem>();
        for(PicklistEntry ple : field.getDescribe().getPicklistValues()){
            items.add(new LabelValueItem(ple.getLabel(), ple.getValue()));
        }
        return items;
    }
    
    public static List<String> getFieldSetList(SObjectType sObjectType, String fieldSetName){
        List<String> resList = new List<String>();
        FieldSet fieldSet = sObjectType.getDescribe().fieldSets.getMap().get(fieldSetName);
        if(fieldSet != null){
            for(FieldSetMember field : fieldSet.getFields()){
                resList.add(field.fieldPath.toLowerCase());
            }
        }
        return resList;
    }
    
    public static String trimForField(String sourceStr, SObjectField field){
        if(sourceStr == null) return sourceStr;
        return sourceStr.mid(0, field.getDescribe().length);
    }


}