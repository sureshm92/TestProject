/**
 * Created by Slav on 07.02.2020.
 */

public without sharing class SO_DataFactoryHelper {
    /**
     * getAllObjects() returns a list of all SObjects available in the system
     *
     * @return
     */
    public static List<String> getAllObjects() {
        List<String> objectList = new List<String>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        List<String> objectNames = new List<String>();
        objectNames.addAll(globalDescribe.keySet());
        objectNames.sort();
        
        for (String objectName : objectNames) {
            DescribeSObjectResult objectDescribe = globalDescribe.get(objectName).getDescribe();
            if (objectDescribe.getKeyPrefix() == null) continue;
            if (objectDescribe.isCustomSetting()) continue;
            if (objectDescribe.isDeprecatedAndHidden()) continue;
            if (!objectDescribe.isAccessible()) continue;
            if (!objectDescribe.isCreateable()) continue;
//          if (!objectDescribe.isUpdateable()) continue;
            if (!objectDescribe.isQueryable()) continue;
            objectList.add(objectDescribe.name + ' [' + objectDescribe.label + ']');
        }
        return objectList;
    }
    
//    public static String getLabelPlural (String objectName) {
//        Schema.getGlobalDescribe().get(objectName).getDescribe().getLabelPlural();
//    }
    
    /**
     * getFields() returns a list of all fields of specified object
     *
     * @param objectName
     *
     * @return
     */
    public static List<SObjectField> getFields(String objectName) {
        List<SObjectField> fields = new List<SObjectField>();
        try {
            Map<String, SObjectField> fieldList = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for (SObjectField field : fieldList.values()) {
                if (!field.getDescribe().isAccessible()) continue;
                if (field.getDescribe().isAiPredictionField()) continue;
                if (field.getDescribe().isAutoNumber()) continue;
                if (field.getDescribe().isCalculated()) continue;
                if (field.getDescribe().isDeprecatedAndHidden()) continue;
                if (field.getDescribe().isEncrypted()) continue;
                fields.add(field);
            }
        } catch (Exception e) {
        }
        return fields;
    }
    
    /**
     * getFieldNames() returns a list of all field names of specified object
     *
     * @param objectName
     *
     * @return
     */
    public static List<String> getFieldNames(String objectName) {
        List<String> names = new List<String>();
        try {
            for (SObjectField field : getFields(objectName)) {
                names.add(field.getDescribe().name);
            }
        } catch (Exception e) {
        }
        names.sort();
        return names;
    }
    
    /**
     * getFieldType() returns one of the following values: BOOLEAN, DATE, PICKLIST, INTEGER or STRING
     *
     * @param objectName
     * @param fieldName
     *
     * @return
     */
    public static String getFieldType(String objectName, String fieldName) {
        try {
            SObjectField field = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
            DescribeFieldResult fieldResult = field.getDescribe();
            if (fieldResult.type == DisplayType.REFERENCE) {
                return DisplayType.REFERENCE.name();
            } else if (fieldResult.type == DisplayType.BOOLEAN) {
                return DisplayType.BOOLEAN.name();
            } else if (fieldResult.type == DisplayType.BASE64) {
                return DisplayType.BASE64.name();
            } else if (fieldResult.type == DisplayType.DATE) {
                return DisplayType.DATE.name();
            } else if (fieldResult.type == DisplayType.DATETIME || fieldResult.type == DisplayType.TIME) {
                return DisplayType.DATETIME.name();
            } else if (fieldResult.type == DisplayType.PICKLIST || fieldResult.type == DisplayType.MULTIPICKLIST) {
                return DisplayType.PICKLIST.name();
            } else if (fieldResult.type == DisplayType.INTEGER || fieldResult.type == DisplayType.DOUBLE || fieldResult.type == DisplayType.LONG ||
                    fieldResult.type == DisplayType.CURRENCY || fieldResult.type == DisplayType.PERCENT) {
                return DisplayType.INTEGER.name();
            } else {
                return DisplayType.STRING.name();
            }
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * getReferenceTo() returns List of reference SObject names for specified field name
     *
     * @param objectName
     * @param fieldName
     *
     * @return
     */
    public static List<String> getReferenceTo (String objectName, String fieldName) {
        List<String> references = new List<String>();
        try {
            for (SObjectType objType : Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getReferenceTo()) {
                references.add(objType.getDescribe().name);
            }
        } catch (Exception e) {
        }
        return references;
    }
    
    /**
     * getPicklistEntries() returns a list of Picklist.Entry for specified Field on specified Object
     *
     * @param objectName
     * @param fieldName
     *
     * @return
     */
    public static List<Schema.PicklistEntry> getPicklistEntries (String objectName, String fieldName) {
        List<Schema.PicklistEntry> picklistEntries = new List<Schema.PicklistEntry>();
        try {
            SObjectField field = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName);
            Schema.DisplayType displayType = field.getDescribe().getType();
            if (displayType == Schema.DisplayType.PICKLIST || displayType == Schema.DisplayType.MULTIPICKLIST) {
                return field.getDescribe().getPicklistValues();
            }
        } catch (Exception e) {
            return new List<Schema.PicklistEntry>();
        }
        return picklistEntries;
    }
    
    /**
     * getPicklistValues() returns a list of Picklist values for specified Field on specified Object
     *
     * @param objectName
     * @param fieldName
     * @param upperCase
     *
     * @return
     */
    public static List<String> getPicklistValues (String objectName, String fieldName, Boolean upperCase) {
        List<String> picklistValues = new List<String>();
        for (PicklistEntry entry : getPicklistEntries(objectName, fieldName)) {
            picklistValues.add(upperCase ? entry.value.toUpperCase() : entry.value);
        }
        return picklistValues;
    }
    
    
    /**
     * createSelectOptions() creates a List<SelectOption> out of provided List<String>
     *
     * @param values
     *
     * @return
     */
    public static List<SelectOption> createSelectOptions (List<String> values, String blankLabel) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        if (blankLabel != null) {
            selectOptions.add(new SelectOption('', blankLabel));
        }
        try {
            for (String value : values) {
                List<String> tokens = value.split(' ');
                selectOptions.add(new SelectOption(tokens[0], value));
            }
        } catch (Exception e) {
            //
        }
        return selectOptions;
    }
    
    /**
     * createSelectOptions() creates a List<SelectOption> out of provided List<Schema.PicklistEntry>
     *
     * @param entries
     * @param blankLabel
     *
     * @return
     */
    public static List<SelectOption> createSelectOptions (List<Schema.PicklistEntry> entries, String blankLabel) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        if (blankLabel != null) {
            selectOptions.add(new SelectOption('', blankLabel));
        }
        try {
            for (Schema.PicklistEntry entry : entries) {
                selectOptions.add(new SelectOption(entry.getValue(), entry.getLabel()));
            }
        } catch (Exception e) {
            //
        }
        return selectOptions;
    }
    
    /**
     * findApexJob() returns List of AsyncApexJob with specified Apex class name
     *
     * @param className
     *
     * @return
     */
    public static List<AsyncApexJob> findApexJobs (String className) {
        if (className == null) return new List<AsyncApexJob>();
        else return [SELECT Status,
                CreatedDate,
                CompletedDate,
                ExtendedStatus,
                ApexClass.Name
        FROM        AsyncApexJob
        WHERE       ApexClass.Name = :className
        ORDER BY    CreatedDate
                DESC
        ];
    }
    
    public static AsyncApexJob getApexJob (String jobId) {
        try {
            return [
                    SELECT Status,
                            CreatedDate,
                            CompletedDate,
                            ExtendedStatus
                    FROM AsyncApexJob
                    WHERE Id = :jobId
            ];
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * listToCSV() converts a List<String> into a CSV
     *
     * @param valueList
     *
     * @return
     */
    public static String listToCSV(List<String> valueList) {
        String csvString = '';
        if (valueList == null) {
            return null;
        }
        
        String comma = '';
        for (String value : valueList) {
            csvString += comma + value;
            comma = ', ';
        }
        return csvString;
    }
    
    /**
     * listToCSV() converts a List<String> into a CSV
     *
     * @param valueList
     *
     * @return
     */
    public static String setToCSV(Set<String> valueSet) {
        return listToCSV(new List<String>(valueSet));
    }

}