/**
 * Created by Leonid Bartenev
 */

public without sharing class TranslationTriggerHandler {
    
    // Handlers: -------------------------------------------------------------------------------------------------------
    
    public class CheckFieldsConsistencyHandler extends TriggerHandler{
        
        public override void beforeInsert(List<SObject> newList) {
            checkFieldsConsistency(newList);
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            checkFieldsConsistency(newList);
        }
    }
    
    // Logic: ----------------------------------------------------------------------------------------------------------
    
    @TestVisible
    private static void checkFieldsConsistency(List<Translation__c> newList){
        List<DisplayType> supportedTypes = new List<DisplayType>{
                DisplayType.STRING,
                DisplayType.TEXTAREA
        };
        List<String> supportedLanguages = new List<String>();
        List<PicklistEntry> picklistEntries = User.LanguageLocaleKey.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry picklistEntry : picklistEntries) supportedLanguages.add(picklistEntry.getValue());
    
        for (Translation__c translation : newList) {
            try {
                if(String.isEmpty(translation.Value__c)){
                    translation.Value__c.addError('Field: "' + Translation__c.Value__c + '" can not be empty');
                }
                Id recordId = Id.valueOf(translation.Record_Id__c);
                translation.Record_Id__c = recordId + '';
                translation.Object_Name__c = recordId.getSobjectType() + '';
                SObjectField sObjectField = recordId.getSobjectType().getDescribe().fields.getMap().get(translation.Field_Name__c);
                if (sObjectField == null) {
                    translation.Field_Name__c.addError('Field: "' + translation.Field_Name__c + '" not found for object: ' + recordId.getSobjectType());
                }else if(!supportedTypes.contains(sObjectField.getDescribe().getType())){
                    translation.Field_Name__c.addError('Unsupported field type. Only string fields are supported. Field type: ' + sObjectField.getDescribe().getType());
                }else if(sObjectField.getDescribe().isCalculated()){
                    translation.Field_Name__c.addError('Formula field not supported for translation');
                }
                translation.Field_Name__c = translation.Field_Name__c.toLowerCase();
                if(!supportedLanguages.contains(translation.Language__c)){
                    translation.Language__c.addError('Unsupported language, code: ' + translation.Language__c);
                }
            } catch (Exception e) {
                translation.Record_Id__c.addError(e.getMessage());
            }
        }
    }

}