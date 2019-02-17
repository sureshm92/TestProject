/**
 * Created by Leonid Bartenev
 */

public class TranslationExportImportRemote {
    
    public class TranslationImportException extends Exception{}
    
    public static String EXPORT_TYPE_BILINGUAL = 'Bilingual';
    public static String EXPORT_TYPE_UNTRANSLATED = 'Untranslated';
    public static String EXPORT_TYPE_SOURCE = 'Source';
    
    @AuraEnabled
    public static String export(Id studyId, String languageCode, String exportType){
        try{
            String exportFile = '<?xml version="1.0" encoding="UTF-8"?>\n' +
                    '<xliff version="1.2">\n' +
                    '    <file original="Salesforce" source-language="en_US" target-language="' + languageCode + '" datatype="xml">\n' +
                    '        <body>\n';
    
            List<Translation__c> translations = [
                    SELECT Id, Value__c, Field_Name__c
                    FROM Translation__c
                    WHERE Record_Id__c =: studyId AND Language__c =: languageCode
            ];
            Map<String, Translation__c> translatedFields = new Map<String, Translation__c>();
            for(Translation__c translation : translations) translatedFields.put(translation.Field_Name__c.toLowerCase(), translation);
            System.debug('TRANSLATED FIELDS: ' + translatedFields);
    
            FieldSet fieldsToTranslate = SObjectType.Clinical_Trial_Profile__c.FieldSets.FieldsToTranslate;
            List<String> queryFields = new List<String>();
            for(FieldSetMember field : fieldsToTranslate.fields) queryFields.add(field.fieldPath);
            
            String query = 'SELECT ' + String.join(queryFields, ',') +
                    ' FROM Clinical_Trial_Profile__c ' +
                    ' WHERE Id =\'' + studyId + '\'';
            Clinical_Trial_Profile__c study = Database.query(query);
            System.debug('QUERY: ' + query);
            
            for(FieldSetMember field : fieldsToTranslate.fields){
                String fieldName = field.getFieldPath().toLowerCase();
                System.debug('FIELD:' + field);
                if(exportType == EXPORT_TYPE_BILINGUAL || exportType == EXPORT_TYPE_SOURCE ||
                        (exportType == EXPORT_TYPE_UNTRANSLATED && !translatedFields.containsKey(fieldName))){
                    Translation__c translation = translatedFields.get(fieldName);
                    if(exportType == EXPORT_TYPE_SOURCE) translation = null;
                    exportFile += generateTranslateUnitXML(study, fieldName, translation);
                }
            }
    
            exportFile += '        </body>\n' +
                    '    </file>\n' +
                    '</xliff>\n';
    
            return exportFile;
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public class ImportResult{
        public Integer importedCount = 0;
        public Integer unimportedCount = 0;
        public Integer deletedCount = 0;
        public String unimportedData;
    }
    
    @AuraEnabled
    public static String importTranslation(String base64File){
        try{
            ImportResult importResult = new ImportResult();
            String fileContent = EncodingUtil.base64Decode(base64File).toString();
            //load XML and check consistency:
            DOM.Document document = new Dom.Document();
            document.load(fileContent);
            DOM.XmlNode rootElem = document.getRootElement();
            if(rootElem.getName() != 'xliff') throw new TranslationImportException('Wrong import file format, can not find root element "xliff"');
            DOM.XmlNode fileElem = rootElem.getChildElement('file', null);
            if(fileElem == null) throw new TranslationImportException('Wrong import file format, can not find "file" element');
            String language = fileElem.getAttribute('target-language', null);
            DOM.XmlNode bodyElemmt = fileElem.getChildElement('body', null);
            if(bodyElemmt == null) throw new TranslationImportException('Wrong import file format, can not find "body" element');
            List<DOM.XmlNode> bodyNodes = bodyElemmt.getChildren();
            Map<String, DOM.XmlNode> translationNodeMap = new Map<String, DOM.XmlNode>();
            List<String> recordIds = new List<String>();
            List<String> fieldNames = new List<String>();
            
            //find translation items in xml:
            for(DOM.XmlNode xmlNode : bodyNodes) {
                if(xmlNode.getName() == 'trans-unit') {
                    String unitId = xmlNode.getAttribute('id', null);
                    List<String> unitIdParts = unitId.split('-');
                    String recordId = unitIdParts[0];
                    String fieldName = unitIdParts[1];
                    recordIds.add(recordId);
                    fieldNames.add(fieldName);
                    translationNodeMap.put(xmlNode.getAttribute('id', null), xmlNode);
                }
            }

            //query existed translations and prepare translatedFieldsMap map:
            List<Translation__c> existedTranslations = [
                    SELECT Id, Record_Id__c, Value__c, Field_Name__c
                    FROM Translation__c
                    WHERE Record_Id__c IN: recordIds AND Field_Name__c IN: fieldNames AND Language__c =: language
            ];
            Map<String, Translation__c> translatedFieldsMap = new Map<String, Translation__c>();
            for(Translation__c t : existedTranslations) translatedFieldsMap.put(t.Record_Id__c + '-' + t.Field_Name__c, t);
    
            //prepare translations list for upserting:
            List<Translation__c> translations = new List<Translation__c>();
            List<Translation__c> translationsForDelete = new List<Translation__c>();
            for(DOM.XmlNode xmlNode : translationNodeMap.values()){
                String unitId = xmlNode.getAttribute('id', null);
                List<String> unitIdParts = unitId.split('-');
                String recordId = unitIdParts[0];
                String fieldName = unitIdParts[1];
                Translation__c translatedItem = translatedFieldsMap.get(unitId);
                if(translatedItem == null) {
                    translatedItem = new Translation__c(
                            Language__c = language,
                            Record_Id__c = recordId,
                            Field_Name__c = fieldName
                    );
                }
                DOM.XmlNode targetElem = xmlNode.getChildElement('target', null);
                if(targetElem != null) {
                    try{
                        Id recordIdCheck = recordId;
                        SObjectField sof = recordIdCheck.getSobjectType().getDescribe().fields.getMap().get(fieldName);
                        if(sof == null){
                            addErrorNode(xmlNode, 'Wrong field name: ' + fieldName);
                            importResult.unimportedCount++;
                        } else if(String.isEmpty(targetElem.getText())){
                            if(translatedItem.Id != null) {
                                translationsForDelete.add(translatedItem);
                                importResult.deletedCount ++;
                            }else{
                                addErrorNode(xmlNode, 'Can not delete record: ' + unitId + '. This record not exist');
                                importResult.unimportedCount++;
                            }
                        }else{
                            translatedItem.Value__c = targetElem.getText().unescapeXml();
                            translations.add(translatedItem);
                        }
                    }catch (Exception e){
                        addErrorNode(xmlNode, e.getMessage());
                        importResult.unimportedCount++;
                    }
                }
            }
            
            //delete translations:
            delete translationsForDelete;
            
            //upsert translations:
            Database.UpsertResult[] updateResult = Database.upsert(translations, false);
            List<DOM.XmlNode> importedNodes = new List<DOM.XmlNode>();
            for(Integer i = 0; i < translations.size(); i++){
                Translation__c unImportedItem = translations[i];
                DOM.XmlNode importedNode = translationNodeMap.get(unImportedItem.Record_Id__c + '-' + unImportedItem.Field_Name__c);
                if(!updateResult[i].isSuccess()){
                    importResult.unimportedCount++;
                    String errors = '';
                    for(Database.Error error: updateResult[i].getErrors()) errors += error.getMessage();
                    addErrorNode(importedNode, errors);
                    importedNodes.add(importedNode);
                }else{
                    importResult.importedCount++;
                    bodyElemmt.removeChild(importedNode);
                }
            }
            if(importResult.unimportedCount > 0) importResult.unimportedData = document.toXmlString();
            return JSON.serialize(importResult);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    public static String generateTranslateUnitXML(SObject so, String fieldName, Translation__c translation){
        String unitId = so.Id + '-' + fieldName;
        Integer length = so.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe().length;
        String unit =
                '            <trans-unit id="'+ unitId + '" maxwidth="' + length + '" size-unit="char">\n';
    
        String source = (String)so.get(fieldName);
        if(source == null) source = '';
        unit +=
                '                <source>' + source.escapeXml() + '</source>\n';
        if(translation != null) unit += '                <target>' + translation.Value__c.escapeXml() + '</target>\n';
        unit += '            </trans-unit>\n';
        return unit;
    }
    
    public static void addErrorNode(DOM.XmlNode node, String message){
        DOM.XmlNode errorNode = node.addChildElement('error', null, null);
        errorNode.addTextNode(message);
    }
    
    

}