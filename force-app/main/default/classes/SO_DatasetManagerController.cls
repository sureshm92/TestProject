/**
 * Created by Slav on 13.02.2020.
 */

public without sharing class SO_DatasetManagerController {
    public final String RESULTS_FILE_NAME  = 'Results.json';
    public final String CONFIG_FILE_NAME   = 'Config.json';

    public class Config {
        public List<ObjectWrap> objectList;
    }

    public class ObjectWrap {
        public String       objectName;
        public List<Field>  fields;
    }

    public class Field {
        public String       name                    { get; set; }
        public String       value                   { get; set; }     // if value starts with '@=>' it means a reference to previously created SObject
        public List<SelectOption>   valueOptions    { get; private set; }
    }

    public class Record {
        public String       objectName              { get; private set; }
        public String       apiName                 { get; private set; }
        public String       recordId                { get; private set; }
        public List<Field>  values                  { get; private set; }   // these are fields with actual values
        public List<Field>  editFields              { get; private set; }   // these are fields for editing
        public String       valueString             { get; private set; }   // it's a JSON-like string for viewing
        public Boolean      error                   { get; private set; }   // true if at least one internal reference not found in advanceObjects
        public Boolean      active                  { get; set; }           // indicates whether this SObject is active

        public void populate (SObject obj) {
            recordId     = obj.Id;
            objectName   = obj.Id.getSobjectType().getDescribe().label;
            apiName      = obj.Id.getSobjectType().getDescribe().name;
            values       = new List<Field>();
            valueString  = '';
            for (String fieldName : SO_DatasetManagerController.getAllFields(apiName)) {
                if (obj.get(fieldName) != null) {
                    Field field = new Field();
                    field.name  = fieldName;
                    field.value = '' + obj.get(fieldName);
                    values.add(field);
                    valueString += '["' + field.name + '"="' + field.value + '"],';
                }
            }
            valueString  = valueString.removeEnd(',');
        }

        public void applyChanges () {
            values = new List<Field>();
            valueString = '';
            if (editFields != null) {
                for (Field editField : editFields) {
                    if (String.isNotBlank(editField.value)) {
                        Field field = new Field();
                        field.name = editField.name;
                        field.value = '' + editField.value;
                        values.add(field);
                        valueString += '["' + field.name + '"="' + field.value + '"],';
                    }
                }
            }
            editFields = null;
        }
    }

    public  Boolean         deployed                { get; private set; }
    public  String          downloadBody            { get; private set; }
    public  String          exportBody              { get; private set; }
    public  String          downloadFileName        { get; private set; }
    public  String          exportFileName          { get; private set; }
    public  String          currentFileName         { get; private set; }
    public  Attachment      configFile              { get { if (configFile == null) configFile = new Attachment(); return configFile; } set; }
    public  Attachment      resultFile              { get { if (resultFile == null) resultFile = new Attachment(); return resultFile; } set; }
    public  List<Record>    createdRecords          { get; private set; }
    public  String          selectedObject          { get; set; }
    public  Integer         index                   { get; set; }

    public  String          selectedObjectLabel     { get; private set; }
    public  List<SelectOption> objectSelectOptions  { get; private set; }
    public  List<Record>    configObjects           { get; private set; }
    public  List<SObject>   queriedRecords          { get; private set; }
    public  Boolean         nameAvailable           { get; private set; }
    public  Boolean         createdDateAvailable    { get; private set; }
    public  Boolean         exportEnabled           { get; private set; }
    public  Boolean         editEnabled             { get; private set; }
    public  Integer         editIndex               { get; private set; }
    public  Integer         configSize              { get; private set; }

    private List<String>    allObjectsLong;
    private List<String>    allObjectsShort;
    private Boolean         testRun;

    /**
     * constructor
     */
    public SO_DatasetManagerController () {
        downloadFileName    = RESULTS_FILE_NAME;
        exportFileName      = CONFIG_FILE_NAME;
        deployed            = false;
        testRun             = false;
        allObjectsLong      = getAllObjects(true);
        allObjectsShort     = getAllObjects(false);
        configObjects       = new List<Record>();
        configSize          = configObjects.size();
        objectSelectOptions = createSelectOptions(allObjectsLong, null, true);
    }

    /**
     * objectChange() method handles an event of changing SObject
     *
     * @return
     */
    public PageReference objectChange() {
        try {
            selectedObjectLabel = '[' + Schema.getGlobalDescribe().get(selectedObject).getDescribe().label + ']';
            queriedRecords = null;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * queryObject() builds a query and runs it to retrieve latest records for selected SObject
     *
     * @return
     */
    public PageReference queryObject() {
        try {
            List<String> fieldNames = getAllFields(selectedObject);
            nameAvailable           = fieldNames.contains('Name');
            createdDateAvailable    = fieldNames.contains('CreatedDate');
            String query            = 'SELECT ';
            for (String fieldName : fieldNames) {
                query += fieldName + ', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM ' + selectedObject + (createdDateAvailable ? ' ORDER BY CreatedDate DESC' : '') + ' LIMIT 50';
            queriedRecords = Database.query(query);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * includeEmptyRecord() creates a new Config element and put it into the Config List (the element has no assigned values)
     *
     * @return
     */
    public PageReference includeEmptyRecord () {
        try {
            SObjectType objType = Schema.getGlobalDescribe().get(selectedObject);
            Record config       = new Record();
            config.objectName   = objType.getDescribe().label;
            config.apiName      = objType.getDescribe().name;
            configObjects.add(config);
            configSize          = configObjects.size();
            prepareConfig();
            exportEnabled       = true;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * includeRecord() creates a new Config element and assigns the values from selected Queried Records
     *
     * @return
     */
    public PageReference includeRecord () {
        try {
            Record record = new Record();
            record.populate(queriedRecords.get(index));
            configObjects.add(record);
            configSize = configObjects.size();
            prepareConfig();
            exportEnabled = true;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * removeRecord() removes an element from Config List
     *
     * @return
     */
    public PageReference removeRecord () {
        try {
            configObjects.remove(index);
            configSize = configObjects.size();
            prepareConfig();
            exportEnabled = !configObjects.isEmpty();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * loadConfig() loads a JSON formatted Config file
     *
     * @return
     */
    public PageReference loadConfig () {
        try {
            String body = EncodingUtil.urlDecode(configFile.Body.toString(), 'UTF-8');
            Config config;

            try {
                config = (Config) JSON.deserialize(body, Config.class);
            } catch (Exception e) {
                configFile.Name = currentFileName;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: File [' + configFile.Name +'] is not a valid JSON file. Please select another one'));
                return null;
            }

            List<Record> newConfig = new List<Record>();
            for (ObjectWrap objectWrap : config.objectList) {
                Record record = new Record();
                record.apiName = objectWrap.objectName;
                record.objectName = Schema.getGlobalDescribe().get(objectWrap.objectName).getDescribe().label;
                record.editFields = objectWrap.fields;
                record.applyChanges();
                newConfig.add(record);
            }

            configObjects = newConfig;
            configSize = configObjects.size();
            prepareConfig();
            currentFileName = configFile.Name;
            exportEnabled = !configObjects.isEmpty();
        } catch (Exception e) {
            configFile.Name = currentFileName;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * editConfig() enables Record editing
     *
     * @return
     */
    public PageReference editConfig () {
        try {
            editIndex   = index;
            Map<String, List<RecordType>> recordTypes = getAllRecordTypes();
            Record record = configObjects[editIndex];
            record.editFields  = new List<Field>();

            Map<String, String> fieldMap = new Map<String, String>();
            for (String fieldName : getAllFields(record.apiName)) {
                fieldMap.put(fieldName, null);
            }

            if (record.values != null) {
                for (Field field : record.values) {
                    fieldMap.put(field.name, field.value);
                }
            }

            Map<String, SObjectField> objectMap = Schema.getGlobalDescribe().get(record.apiName).getDescribe().fields.getMap();
            for (String fieldName : fieldMap.keySet()) {
                Field field = new Field();
                field.name  = fieldName;
                field.value = fieldMap.get(fieldName);

                // ------ this block prepares value options for field types: REFERENCE, RECORDTYPE, PICKLIST ------
                if (objectMap.get(fieldName) == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                            'Field [' + fieldName + '] is not available in Object [' + record.apiName + ']. It will be dropped if you apply changes.'));
                    record.error = true;
                    continue;
                }
                DescribeFieldResult fieldResult = objectMap.get(fieldName).getDescribe();
                if (fieldResult.getType() == DisplayType.REFERENCE) {
                    for (SObjectType objectType : fieldResult.getReferenceTo()) {
                        String reference = objectType.getDescribe().name;
                        if (allObjectsShort.contains(reference)) {
                            if (field.valueOptions == null) {
                                field.valueOptions = new List<SelectOption>();
                            }
                            field.valueOptions.add(new SelectOption(reference, reference));
                        }
                        if (reference == 'RecordType') {
                            if (field.valueOptions == null) {
                                field.valueOptions = new List<SelectOption>();
                            }
                            for (RecordType recType : recordTypes.get(record.apiName)) {
                                field.valueOptions.add(new SelectOption(recType.Id, recType.Name));
                            }
                        }
                    }
                } else if (fieldResult.getType() == DisplayType.PICKLIST || fieldResult.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    if (field.valueOptions == null) {
                        field.valueOptions = new List<SelectOption>();
                    }
                    for (PicklistEntry entry : fieldResult.getPicklistValues()) {
                        String entryValue = entry.value;
                        String entryLabel = entry.label;
                        if (String.isBlank(entryLabel)) entryLabel = entryValue;
                        field.valueOptions.add(new SelectOption(entryValue, entryLabel));
                    }
                }

                record.editFields.add(field);
            }

            editEnabled = true;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * moveUp() moves current line in the Config list one row up
     *
     * @return
     */
    public PageReference moveUp () {
        try {
            configObjects.add(index - 1, configObjects.remove(index));
            prepareConfig();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * moveDown() moves current line in the Config list one row down
     *
     * @return
     */
    public PageReference moveDown () {
        try {
            Record record = configObjects.remove(index);
            if (index == configObjects.size() - 1) {
                configObjects.add(record);
            } else {
                configObjects.add(index + 1, record);
            }
            prepareConfig();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * applyChanges() applies changes on current SObject
     *
     * @return
     */
    public PageReference applyChanges () {
        try {
            configObjects[editIndex].applyChanges();
            prepareConfig();
            editIndex   = -1;
            editEnabled = false;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * cancelEdit() cancels changes and exit Edit mode
     *
     * @return
     */
    public PageReference cancelEdit () {
        try {
            configObjects[editIndex].editFields = null;
            editIndex   = -1;
            editEnabled = false;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * testRun() invoked from Create Tab, attempts to create current Config build in Test mode
     *
     * @return
     */
    public PageReference testRun () {
        try {
            testRun = true;
            configFile.Body = EncodingUtil.base64Decode(exportBody);
            startCreate();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        testRun = false;
        return null;
    }

    /**
     * startCreate() processes specified Config file and creates defined SObjects
     *
     * @return
     */
    public PageReference startCreate () {
        Savepoint savePoint = Database.setSavepoint();
        String failedObject;
        try {
            List<String> createdObjNames = new List<String>();
            List<SObject> createdObjects = new List<SObject>();
            Boolean error = false;

            if (configFile.Body == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Configuration file not selected'));
                return null;
            }

            String body = EncodingUtil.urlDecode(configFile.Body.toString(), 'UTF-8');
            Config config = (Config) JSON.deserialize(body, Config.class);

            Integer sectionIndex = 0;
            for (ObjectWrap objectWrap : config.objectList) {
                failedObject = objectWrap.objectName;
                sectionIndex++;
                if (String.isBlank(objectWrap.objectName)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Object API name not provided in Meta section [' + sectionIndex + ']'));
                    error = true;
                    continue;
                } else if (!allObjectsShort.contains(objectWrap.objectName)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Object doesn\'t exist: [' + objectWrap.objectName + ']'));
                    error = true;
                    continue;
                }

                SObject obj = Schema.getGlobalDescribe().get(objectWrap.objectName).newSObject();
                List<String> allFieldList = getAllFields(objectWrap.objectName);

                if (objectWrap.fields != null) {
                    for (Field field : objectWrap.fields) {
                        // ------ check if field name is provided
                        if (String.isBlank(field.name)) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Field name not provided for Object [' +
                                    objectWrap.objectName + ']'));
                            error = true;
                            continue;
                        }

                        // ------ check if field exist in Object
                        if (!allFieldList.contains(field.name)) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Field name [' +
                                    field.name + '] doesn\'t exist in Object [' + objectWrap.objectName + ']'));
                            error = true;
                            continue;
                        }

                        DisplayType fieldType = obj.getSObjectType().getDescribe().fields.getMap().get(field.name).getDescribe().getType();
                        if (fieldType == DisplayType.REFERENCE) {
                            String fieldValue = field.value;
                            if (fieldValue != null && allObjectsShort.contains(fieldValue)) {   // check if field value is an internal reference
                                Integer lastIndex = lastIndexOf(createdObjNames, fieldValue);   // if so, then try to find if such SObject has been created
                                if (lastIndex >= 0) {
                                    field.value = createdObjects.get(lastIndex).Id;
                                } else {
                                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Reference [' +
                                            field.value + '] for field [' + field.name + '] in Object [' + objectWrap.objectName + '] cannot be resolved. Record hasn\'t been created yet.'));
                                    error = true;
                                }
                            }
                            obj.put(field.name, field.value);
                        } else if (fieldType == DisplayType.BOOLEAN) {
                            obj.put(field.name, Boolean.valueOf(field.value));
                        } else if (fieldType == DisplayType.DATE) {
                            obj.put(field.name, Date.valueOf(field.value));
                        } else if (fieldType == DisplayType.DATETIME) {
                            obj.put(field.name, Datetime.valueOf(field.value));
                        } else if (fieldType == DisplayType.INTEGER) {
                            obj.put(field.name, Integer.valueOf(field.value));
                        } else if (fieldType == DisplayType.DOUBLE) {
                            obj.put(field.name, Double.valueOf(field.value));
                        } else if (fieldType == DisplayType.LONG) {
                            obj.put(field.name, Long.valueOf(field.value));
                        } else {
                            obj.put(field.name, field.value);
                        }
                    }
                }

                if (error) continue;

                insert obj;
                createdObjNames.add(obj.getSObjectType().getDescribe().name);
                createdObjects.add(obj);
            }

            if (!error) {
                if (testRun) {
                    Database.rollback(savePoint);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'TEST SUCCESS: This config would have created ' + createdObjects.size() + ' objects'));
                } else {
                    createdRecords = prepareRecords(createdObjects);
                    downloadBody = EncodingUtil.base64Encode(Blob.valueOf(JSON.serializePretty(createdObjects)));
                    resultFile.Name = 'Created SObjects.json';
                    resultFile.Body = Blob.valueOf(EncodingUtil.urlEncode(JSON.serialize(createdObjects), 'UTF-8'));
                    configFile = new Attachment();
                    deployed = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'SUCCESS: Created ' + createdObjects.size() + ' objects'));
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, '[' + failedObject + ']: ' + e.getMessage()));
            Database.rollback(savePoint);
        }
        return null;
    }

    /**
     * startDelete() processes specified Result file with JSON serialized Objects and deletes them from Database
     *
     * @return
     */
    public PageReference startDelete () {
        Savepoint savePoint = Database.setSavepoint();
        try {
            List<SObject> resultObjects = new List<SObject>();
            List<Id> resultIds = new List<Id>();
            Boolean error = false;

            if (resultFile.Body == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'ERROR: Deploy result file not selected'));
                return null;
            }

            String body = EncodingUtil.urlDecode(resultFile.Body.toString(), 'UTF-8');
            resultObjects = (List<SObject>) JSON.deserialize(body, List<SObject>.class);

            if (!resultObjects.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The following Objects requested to be deleted:'));
            }

            for (SObject obj : resultObjects) {
                resultIds.add(obj.Id);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, '&nbsp;&nbsp;&nbsp;&nbsp;[' +
                        obj.Id.getSobjectType().getDescribe().name + ' : ' + obj.Id + ']'));
            }

            List<Database.DeleteResult> deleteResults = Database.delete(resultObjects, false);
            Integer successCount = 0;
            for (Database.DeleteResult deleteResult : deleteResults) {
                if (deleteResult.success) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Object [' +
                            deleteResult.Id.getSobjectType().getDescribe().name + ' : ' + deleteResult.Id + '] successfully deleted'));
                    successCount++;
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, '[' +
                            deleteResult.Id.getSobjectType().getDescribe().name + ' : ' + deleteResult.Id + '] ' +
                            deleteResult.getErrors().get(0).message));
                }
            }

            createdRecords = null;
            resultFile  = new Attachment();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Total ' + successCount + ' objects deleted'));

        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
            Database.rollback(savePoint);
        }
        return null;
    }

    /**
     * prepareRecords() prepares newly created records to display on the page
     *
     * @param createdObjects
     *
     * @return
     */
    private List<Record> prepareRecords (List<SObject> createdObjects) {
        List<Record> records = new List<Record>();
        for (SObject obj : createdObjects) {
            Record record       = new Record();
            record.recordId     = obj.Id;
            record.objectName   = obj.Id.getSobjectType().getDescribe().label;
            record.apiName      = obj.Id.getSobjectType().getDescribe().name;
            records.add(record);
        }
        return records;
    }

    /**
     * prepareConfig() processes the Config List, converts it into a JSON string
     *
     * @return
     */
    private void prepareConfig () {
        try {
            Config config       = new Config();
            config.objectList   = new List<ObjectWrap>();
            List<String> advanceObjects = new List<String>();
            for (Record record : configObjects) {
                Map<String, SObjectField> fieldMap = Schema.getGlobalDescribe().get(record.apiName).getDescribe().fields.getMap();
                record.error = false;
                if (record.values != null) {
                    for (Field field : record.values) {
                        SObjectField soField = fieldMap.get(field.name);
                        if (soField == null) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                    'INVALID CONFIG: Field [' + field.name + '] doesn\'t exist in Object [' + record.apiName + ']'));
                            record.error = true;
                            continue;
                        }
                        if (fieldMap.get(field.name).getDescribe().getType() == DisplayType.REFERENCE && allObjectsShort.contains(field.value)) {
                            if (!advanceObjects.contains(field.value)) {      // if field.value is a Reference, but it's not found in advanceObjects then set ERROR
                                record.error = true;
                            }
                        }
                    }
                }
                advanceObjects.add(record.apiName);

                ObjectWrap objectWrap   = new ObjectWrap();
                objectWrap.objectName   = record.apiName;
                objectWrap.fields       = record.values;
                config.objectList.add(objectWrap);
            }
            exportBody = EncodingUtil.base64Encode(Blob.valueOf(JSON.serializePretty(config)));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
    }

    /**
     * getAllObjects() returns a list of all SObjects available in the system
     *
     * @return
     */
    private List<String> getAllObjects (Boolean includeLabel) {
        List<String> objectList = new List<String>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        List<String> objectNames = new List<String>();
        objectNames.addAll(globalDescribe.keySet());
        objectNames.sort();

        for (String objectName : objectNames) {
            DescribeSObjectResult objectDescribe = globalDescribe.get(objectName).getDescribe();
            if (!objectDescribe.isCreateable()) continue;
            if (includeLabel) {
                objectList.add(objectDescribe.name + ' [' + objectDescribe.label + ']');
            } else {
                objectList.add(objectDescribe.name);
            }
        }
        return objectList;
    }

    /**
     * getAllFields() returns a list of all fields for specified object
     *
     * @param objectName
     *
     * @return
     */
    private static List<String> getAllFields (String objectName) {
        List<String> fields = new List<String>();
        try {
            Map<String, SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for (SObjectField field : fieldMap.values()) {
                DescribeFieldResult fieldDescribe = field.getDescribe();
                if (!fieldDescribe.isCreateable()) continue;
                fields.add(fieldDescribe.name);
            }
            fields.sort();
        } catch (Exception e) {
        }
        return fields;
    }

    /**
     * getAllRecordTypes() returns Map of all RecordTypes available in Org with SObject types as Keys
     *
     * @return
     */
    private Map<String, List<RecordType>> getAllRecordTypes () {
        Map<String, List<RecordType>> recordTypes = new Map<String, List<RecordType>>();
        try {
            for (RecordType recType : [SELECT Name, DeveloperName, SobjectType FROM RecordType]) {
                List<RecordType> typeList = recordTypes.get(recType.SobjectType);
                if (typeList == null) {
                    typeList = new List<RecordType>();
                    recordTypes.put(recType.SobjectType, typeList);
                }
                typeList.add(recType);
            }
        } catch (Exception e) {
        }
        return recordTypes;
    }

    /**
     * createSelectOptions()
     *
     * @param values
     * @param blankLabel
     * @param split
     *
     * @return
     */
    private List<SelectOption> createSelectOptions (List<String> values, String blankLabel, Boolean split) {
        List<SelectOption> selectOptions = new List<SelectOption>();
        if (blankLabel != null) {
            selectOptions.add(new SelectOption('', blankLabel));
        }
        try {
            for (String value : values) {
                if (split) {
                    List<String> tokens = value.split(' ');
                    selectOptions.add(new SelectOption(tokens[0], value));
                } else {
                    selectOptions.add(new SelectOption(value, value));
                }
            }
        } catch (Exception e) {
            //
        }
        return selectOptions;
    }

    /**
     * lastIndexOf() returns last index of specified Object in provided List or -1 if not found
     *
     * @param objList
     * @param value
     *
     * @return
     */
    private Integer lastIndexOf (List<Object> objList, Object value) {
        try {
            Integer index = -1, lastIndex = -1;
            for (Object obj : objList) {
                index++;
                if (obj == value) lastIndex = index;
            }
            return lastIndex;
        } catch (Exception e) {
            return -1;
        }
    }
}
