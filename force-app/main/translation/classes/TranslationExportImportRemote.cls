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
            return generateExportTranslationFile(
                    exportTranslationForStudy(studyId, languageCode, exportType),
                    languageCode
            );
        }catch (Exception e){
            return (String)AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static String exportPlatformData(String languageCode, String exportType){
        try{
            return generateExportTranslationFile(
                    generatePlatformLevelTranslatableObjectsItems(languageCode, exportType),
                    languageCode
            );
        }catch (Exception e){
            return (String)AuraHelper.throwException(e);
        }
    }

    @AuraEnabled
    public static String exportVisitPlan(Id visitPlanId, String languageCode, String exportType){
        try{
            return generateExportTranslationFile(
                    exportTranslationForVisitPlan(visitPlanId, languageCode, exportType) +
                            exportTranslationForVisitPlanIconDetails(visitPlanId, languageCode, exportType),
                    languageCode
            );
        }catch (Exception e) {
            return (String)AuraHelper.throwException(e);
        }
    }
    
    @AuraEnabled
    public static List<Platform_Level_Translatable_Objects__mdt> getPlatformLevelTranslatableObjects(){
        try{
            return [SELECT Id, Label, SObject_Name__c FROM Platform_Level_Translatable_Objects__mdt];
        }catch (Exception e){
            return (List<Platform_Level_Translatable_Objects__mdt>) AuraHelper.throwException(e);
        }
    }
    
    public static String generateExportTranslationFile(String items, String languageCode){
        String exportFile =
                '<?xml version="1.0" encoding="UTF-8"?>\n' +
                '<xliff version="1.2">\n' +
                '    <file original="Salesforce" source-language="en_US" target-language="' + languageCode + '" datatype="xml">\n' +
                '        <body>\n';
    
        exportFile += items;
    
        exportFile +=
                '        </body>\n' +
                '    </file>\n' +
                '</xliff>\n';
        return exportFile;
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
            return (String)AuraHelper.throwException(e);
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
    
    public static String exportTranslationForStudy(Id studyId, String languageCode, String exportType){
        return generateItemsForSObjectType(Clinical_Trial_Profile__c.getSObjectType(), ' WHERE Id =\'' + studyId + '\'', languageCode, exportType);
    }
    
    public static String exportTranslationForStudyVisitPlan(Id studyId, String languageCode, String exportType){
        Id visitPlanId = [SELECT Id, Visit_Plan__c FROM Clinical_Trial_Profile__c WHERE Id =: studyId].Visit_Plan__c;
        return generateItemsForSObjectType(Visit__c.getSObjectType(), ' WHERE Visit_Plan__c =\'' + visitPlanId + '\'', languageCode, exportType) +
                generateItemsForSObjectType(Icon_Details__c.getSObjectType(), ' WHERE Visit_Plan__c =\'' + visitPlanId + '\'', languageCode, exportType);
    }

    public static String exportTranslationForVisitPlan(Id visitPlanId, String languageCode, String exportType){
        return generateItemsForSObjectType(Visit__c.getSObjectType(), ' WHERE Visit_Plan__c =\'' + visitPlanId + '\'', languageCode, exportType);
    }

    public static String exportTranslationForVisitPlanIconDetails(Id visitPlanId, String languageCode, String exportType){
        return generateItemsForSObjectType(Icon_Details__c.getSObjectType(), ' WHERE Visit_Plan__c =\'' + visitPlanId + '\'', languageCode, exportType);
    }
    
    public static String generatePlatformLevelTranslatableObjectsItems(String languageCode, String exportType){
        String result = '';
        List<Platform_Level_Translatable_Objects__mdt> translatableObjects = [
                SELECT Id, SObject_Name__c
                FROM Platform_Level_Translatable_Objects__mdt
        ];
        for(Platform_Level_Translatable_Objects__mdt to : translatableObjects){
            result += generateItemsForSObjectType(Schema.getGlobalDescribe().get(to.SObject_Name__c), null, languageCode, exportType);
        }
        return result;
    }
    
    public static String generateItemsForSObjectType(SObjectType sObjectType, String whereFilter, String languageCode, String exportType){
        String result = '';
        if(whereFilter == null) whereFilter = '';
        if(sObjectType == null) return '';
        List<String> fieldsToTranslate = SObjectHelper.getFieldSetList(sObjectType, 'FieldsToTranslate');
        if(fieldsToTranslate.isEmpty()) return '';
        String query = 'SELECT ' + String.join(fieldsToTranslate, ',') +
                ' FROM ' + sObjectType.getDescribe().getName() + ' ' + whereFilter;
        Map<Id, SObject> sObjectsMap = new Map<Id, SObject>(Database.query(query));

        if(sObjectType == Icon_Details__c.SObjectType){
            for(Id currId : sObjectsMap.keySet()) {
                if(((Icon_Details__c)sObjectsMap.get(currId)).Description__c == null &&
                        ((Icon_Details__c)sObjectsMap.get(currId)).Label__c == null) {
                    sObjectsMap.remove(currId);
                }
            }
        }

        List<Translation__c> translations = [
                SELECT Id, Value__c, Field_Name__c, Record_Id__c
                FROM Translation__c
                WHERE Record_Id__c IN: sObjectsMap.keySet() AND Language__c =: languageCode
        ];
        Map<String, Translation__c> translatedFieldsMap = new Map<String, Translation__c>();
        for(Translation__c translation : translations) {
            translatedFieldsMap.put(
                    translation.Record_Id__c + translation.Field_Name__c.toLowerCase(),
                    translation
            );
        }
    
        for(SObject sObj : sObjectsMap.values()){
            for(String fieldName : fieldsToTranslate){
                if(exportType == EXPORT_TYPE_BILINGUAL || exportType == EXPORT_TYPE_SOURCE ||
                        (exportType == EXPORT_TYPE_UNTRANSLATED && !translatedFieldsMap.containsKey(sObj.Id + fieldName))){
                    Translation__c translation = translatedFieldsMap.get(fieldName);
                    if(exportType == EXPORT_TYPE_SOURCE) translation = null;
                    result += generateTranslateUnitXML(sObj, fieldName, translation);
                }
            }
        }
        return result;
    }
    
}