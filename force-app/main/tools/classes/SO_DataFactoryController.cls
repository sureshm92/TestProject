/**
 * Created by Slav on 06.02.2020.
 */

public without sharing class SO_DataFactoryController {
    public class LookupWrapper {
        public String           objectName  { get; private set; }
        public String           objectLabel { get; private set; }
        public List<SObject>    records     { get; private set; }
    }
    
    public List<SelectOption>   objectSelectOptions { get; private set; }
    public List<SelectOption>   fieldSelectOptions  { get; private set; }
    public List<SelectOption>   booleanOptions      { get; private set; }
    public List<SelectOption>   fields              { get; private set; }
    public List<LookupWrapper>  wrappers            { get; private set; }
    public Boolean              showLookup          { get; private set; }

    public String               lookupField         { get; set; }
    public String               lookupId            { get; set; }
    public Integer              fieldIndex          { get; set; }
    public Integer              recordIndex         { get; set; }
    public String               selectedObject      { get; set; }
    public List<SO_FieldMeta>   fieldMetas          { get; set; }
    public List<String>         records             { get; private set; }   // this List contains records prepared for display on the Page
    private List<SObject>       recordSet;                                  // this is a List of raw records retrieved from Database, it's not accessible from the Page
    
    /**
     * constructor
     */
    public SO_DataFactoryController () {
        objectSelectOptions     = SO_DataFactoryHelper.createSelectOptions(SO_DataFactoryHelper.getAllObjects(), '-- select object --', true);
        booleanOptions          = SO_DataFactoryHelper.createSelectOptions(new List<String>{ 'TRUE', 'FALSE' }, null, false);
    }
    
    /**
     * objectChange() method handles an event of changing SObject and creates a new list of fields
     *
     * @return
     */
    public PageReference objectChange() {
        try {
            fieldSelectOptions = SO_DataFactoryHelper.createSelectOptions(SO_DataFactoryHelper.getFieldNames(selectedObject), '-- select field --', true);
            fieldMetas  = new List<SO_FieldMeta>();
            records     = new List<String>();
            if (selectedObject != null) {
                fieldMetas.add(new SO_FieldMeta());
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }
    
    /**
     * fieldChange() this method is invoked when list of selected fields is changed
     *
     * @return
     */
    public PageReference fieldChange() {
        try {
            SO_FieldMeta fieldMeta      = fieldMetas.get(fieldIndex);
            fieldMeta.stringValue       = null;
            fieldMeta.fieldType         = SO_DataFactoryHelper.getFieldType(selectedObject, fieldMeta.fieldName);
            fieldMeta.relationshipName  = SO_DataFactoryHelper.getRelationshipName(selectedObject, fieldMeta.fieldName) + '.Name';
            fieldMeta.picklistOptions   = SO_DataFactoryHelper.createSelectOptions(SO_DataFactoryHelper.getPicklistValues(selectedObject, fieldMeta.fieldName, true), null, false);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * showLookupDialog() queries records on selected SObject and enables the Lookup Dialog
     *
     * @return
     */
    public PageReference showLookupDialog () {
        List<String> references = SO_DataFactoryHelper.getReferenceTo(selectedObject, lookupField);
        if (references.isEmpty()) return null;
        if (references.size() > 10) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,
                    'There are too many SObject types that can be referenced by this field [' + lookupField + ']. Please enter an Id manually'));
            return null;
        }

        wrappers = new List<LookupWrapper>();
        for (String objectName : references) {
            LookupWrapper wrapper   = new LookupWrapper();
            wrapper.objectName      = objectName;
            wrapper.objectLabel     = Schema.getGlobalDescribe().get(objectName).getDescribe().getLabelPlural();
            String objTypeFilter    = '';
            if (Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get('SobjectType') != null) {
                objTypeFilter       = ' WHERE SobjectType = \'' + selectedObject + '\'';
            }
            wrapper.records         = Database.query('SELECT Id, Name FROM ' + objectName + objTypeFilter + ' ORDER BY CreatedDate DESC LIMIT 20');
            wrappers.add(wrapper);
        }

        showLookup = true;
        return null;
    }
    
    /**
     * assignLookupId() assigns Reference field with selected lookup record Id
     *
     * @return
     */
    public PageReference assignLookupId () {
        SO_FieldMeta fieldMeta  = fieldMetas.get(fieldIndex);
        fieldMeta.stringValue   = lookupId;
        showLookup              = false;
        return null;
    }

    /**
     * closeLookupDialog() closes the Lookup Dialog box
     *
     * @return
     */
    public PageReference closeLookupDialog () {
        showLookup = false;
        return null;
    }
    
    /**
     * addField() adds a new SO_FieldMeta
     *
     * @return
     */
    public PageReference addField() {
        try {
            if (fieldMetas.size() <= fieldIndex + 1) {
                fieldMetas.add(new SO_FieldMeta());
            } else {
                fieldMetas.add(fieldIndex + 1, new SO_FieldMeta());
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }
    
    /**
     * delField() removes current SO_FieldMeta from list
     *
     * @return
     */
    public PageReference delField() {
        try {
            if (fieldMetas.size() > 1) {
                fieldMetas.remove(fieldIndex);
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }
    
    /**
     * createRecord()
     *
     * @return
     */
    public PageReference createRecord() {
        try {
            if (selectedObject == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'It would be a good idea if you select an Object'));
            } else {
                SObject obj = Schema.getGlobalDescribe().get(selectedObject).newSObject() ;
                for (SO_FieldMeta fieldMeta : fieldMetas) {
                    if (fieldMeta.fieldName == null) continue;
                    if (fieldMeta.fieldType == 'INTEGER') {
                        obj.put(fieldMeta.fieldName, fieldMeta.intValue);
                    } else if (fieldMeta.fieldType == 'PICKLIST') {
                        obj.put(fieldMeta.fieldName, fieldMeta.picklistValue);
                    } else if (fieldMeta.fieldType == 'BOOLEAN') {
                        obj.put(fieldMeta.fieldName, fieldMeta.booleanValue);
                    } else if (fieldMeta.fieldType == 'BASE64') {
                        obj.put(fieldMeta.fieldName, EncodingUtil.base64Decode(fieldMeta.stringValue));
                    } else if (fieldMeta.fieldType == 'DATE') {
                        obj.put(fieldMeta.fieldName, fieldMeta.dateValue);
                    } else if (fieldMeta.fieldType == 'DATETIME') {
                        obj.put(fieldMeta.fieldName, fieldMeta.datetimeValue);
                    } else {    // assume the type is STRING
                        obj.put(fieldMeta.fieldName, fieldMeta.stringValue);
                    }
                }
                insert obj;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record successfully created'));
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage()));
        }
        return null;
    }
    
    /**
     * recentRecords()
     *
     * @return
     */
    public PageReference recentRecords() {
        try {
            if (selectedObject == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'It would be a good idea if you select an Object'));
            } else {
                records = new List<String>();
                Set<String> fieldNames = new Set<String> { 'Id', 'Name', 'CreatedDate' };
                
                for (SO_FieldMeta fieldMeta : fieldMetas) {
                    if (fieldMeta.fieldName != null) {
                        fieldNames.add(fieldMeta.fieldName);
                        if (fieldMeta.fieldType == 'REFERENCE' && fieldMeta.relationshipName != null) {
                            fieldNames.add(fieldMeta.relationshipName);
                        }
                    }
                }
                
                // ------ check if Name field is available on the Object ------
                if (Schema.getGlobalDescribe().get(selectedObject).getDescribe().fields.getMap().get('Name') == null) {
                    fieldNames.remove('Name');
                }
                
                String query = 'SELECT ' + SO_DataFactoryHelper.setToCSV(fieldNames) + ' FROM ' + selectedObject + ' ORDER BY CreatedDate DESC LIMIT 10';
                recordSet = Database.query(query);
                for (SObject obj : recordSet) {
                    String record = '';
                    for (String fieldName : fieldNames) {
                        if (fieldName.contains('.')) {
                            List<String> tokens = fieldName.split('\\.');
                            String referenceName = (String) obj.getSObject(tokens[0]).get(tokens[1]);
                            Integer idx = record.lastIndexOf('], ');
                            record = record.removeEnd('], ') + ':"' + referenceName + '"], ';
                        } else {
                            record += '[' + fieldName + '=' + obj.get(fieldName) + '], ';
                        }
                    }
                    records.add(record.trim().removeEnd(','));
                }
                
                if (records.isEmpty()) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No records on [' + selectedObject + '] were found'));
                }
            }
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

    /**
     * deleteRecord()
     *
     * @return
     */
    public PageReference deleteRecord() {
        try {
            SObject obj = recordSet.get(recordIndex);
            delete obj;
            recentRecords();
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'EXCEPTION: ' + e.getMessage() + ' ' + e.getStackTraceString()));
        }
        return null;
    }

}