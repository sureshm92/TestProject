/**
 * Created by Leonid Bartenev
 */

public class TranslateHelper {
    public static final String DEFAULT_LANGUAGE = 'en_US';

    public static void translate(SObject so) {
        translate(new List<SObject>{ so }, UserInfo.getLanguage());
    }

    public static void translate(SObject so, String language) {
        translate(new List<SObject>{ so }, language);
    }

    public static void translate(List<SObject> inputRecords) {
        translate(inputRecords, UserInfo.getLanguage());
    }
    public static void translate(List<SObject> inputRecords, String language) {
        if (inputRecords == null || inputRecords.size() == 0)
            return;
        List<SObject> recordsList = SObjectHelper.getAllSObjects(inputRecords);
        //for(SObject sobj : inputRecords) recordsList.addAll(SObjectHelper.getAllSObjects(sobj));

        List<Id> recordIds = new List<Id>();
        for (SObject so : recordsList) {
            if (so.Id != null)
                recordIds.add(so.Id);
        }

        if (language == null)
            language = UserInfo.getLanguage();
        List<Translation__c> translations = [
            SELECT Id, Field_Name__c, Language__c, Object_Name__c, Record_Id__c, Value__c
            FROM Translation__c
            WHERE Record_Id__c IN :recordIds AND Language__c = :language
        ];
        //for(Translation__c translation : translations) System.debug('TRANSLATION: ' + translation);
        Map<Id, List<Translation__c>> translationMap = new Map<Id, List<Translation__c>>();
        for (Translation__c translation : translations) {
            List<Translation__c> recordTranslations = translationMap.get(translation.Record_Id__c);
            if (recordTranslations == null)
                recordTranslations = new List<Translation__c>();
            recordTranslations.add(translation);
            translationMap.put(translation.Record_Id__c, recordTranslations);
        }
        for (SObject so : recordsList) {
            if (so.Id == null) {
                System.debug('ERROR: Can not translate record without record Id: ' + so);
                return;
            }
            List<Translation__c> recordTranslations = translationMap.get(so.Id);
            if (recordTranslations == null)
                continue;
            for (Translation__c translation : recordTranslations) {
                try {
                    so.put(translation.Field_Name__c, translation.Value__c);
                } catch (Exception e) {
                    System.debug(
                        'ERROR: can not translate record: ' +
                        so +
                        ' Translation: ' +
                        translation
                    );
                    System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
                }
            }
        }
    }

    /*@Future(Callout=true)
    public static void translateNotificationsFuture(Set<Id> notificationIds){
        List<VTD1_NotificationC__c> notifications = [
                SELECT Id, OwnerId,
                        Title__c,
                        Message__c,
                        VTD2_Title_Parameters__c,
                        VTD1_Parameters__c
                FROM VTD1_NotificationC__c
                WHERE Id IN: notificationIds
        ];
        translate(notifications, true);
        update notifications;
    }
    
    public static void translate(List<VTD1_NotificationC__c> notifications){
        translate(notifications, false);
    }
    
    public static void translate(List<VTD1_NotificationC__c> notifications, Boolean useOwnerLanguage){
        //define pairs: field with label - field with parameters:
        Map<String, String> fieldsMap = new Map<String, String> {
                VTD1_NotificationC__c.Title__c + '' => VTD1_NotificationC__c.VTD2_Title_Parameters__c + '',
                VTD1_NotificationC__c.Message__c + '' => VTD1_NotificationC__c.VTD1_Parameters__c + ''
        };
        //translate labels:
        prepareLabelFields(notifications, fieldsMap.keySet(), useOwnerLanguage);
        //substitute params:
        substituteParameters(notifications, fieldsMap);
    }
    
    public static void translate(List<Task> tasksList){
        //define pairs: field with label - field with parameters:
        Map<String, String> fieldsMap = new Map<String, String> {
                Task.Subject + '' => Task.VTD2_Subject_Parameters__c + '',
                Task.Description + '' => Task.VTD2_Description_Parameters__c + ''
        };
        //translate labels:
        prepareLabelFields(tasksList, fieldsMap.keySet());
        //substitute params:
        substituteParameters(tasksList, fieldsMap);
    }
    */

    public static Map<String, Map<String, String>> labelValuesMap = new Map<String, Map<String, String>>();

    public static String getLabelValue(String labelName) {
        System.debug('#language: ' + UserInfo.getLanguage());
        return getLabelValue(labelName, UserInfo.getLanguage());
    }

    public static String getLabelValue(String labelName, String language) {
        Map<String, String> labelValuesForLanguage = labelValuesMap.get(language);
        System.debug('IN getLabelValue: ' + labelValuesForLanguage);
        if (labelValuesForLanguage == null) {
            labelValuesForLanguage = new Map<String, String>();
            labelValuesMap.put(language, labelValuesForLanguage);
        }
        String translatedLabel = labelValuesForLanguage.get(labelName);
        if (translatedLabel == null) {
            try {
                PageReference pageRef = Page.CustomLabelRenderPage;
                pageRef.getParameters()
                    .putAll(
                        new Map<String, String>{ 'labelName' => labelName, 'lang' => language }
                    );
                translatedLabel = pageRef.getContent().toString().trim();
            } catch (Exception e) {
                translatedLabel = labelName;
                System.debug('#151: ' + e.getMessage());
                //translatedLabel = 'Profile: ' + UserInfo.getProfileId() + '  User: ' + UserInfo.getUserId() + ' ERROR: ' + e.getMessage() + ' ' + e.getStackTraceString();
            }
            labelValuesForLanguage.put(labelName, translatedLabel);
        }
        System.debug('LABEL: ' + labelName);
        System.debug('LANGUAGE: ' + language);
        System.debug('RESULT: ' + translatedLabel);
        if (
            translatedLabel != null &&
            translatedLabel.contains('To access this page, you have to log in to Salesforce')
        )
            return labelName;
        return translatedLabel;
    }

    public static void prepareLabelFields(SObject record, Set<String> fieldNames) {
        prepareLabelFields(new List<SObject>{ record }, fieldNames, false);
    }

    public static void prepareLabelFields(List<SObject> records, Set<String> fieldNames) {
        prepareLabelFields(records, fieldNames, false);
    }

    public static void prepareLabelFields(
        List<SObject> records,
        Set<String> fieldNames,
        Boolean useOwnerLanguage
    ) {
        Map<Id, String> userLanguageMap = new Map<Id, String>();
        if (useOwnerLanguage) {
            List<Id> useIds = new List<Id>();
            for (SObject sobj : records)
                useIds.add((Id) sobj.get('OwnerId'));
            List<User> users = [SELECT Id, LanguageLocaleKey FROM User WHERE Id IN :useIds];
            for (User user : users)
                userLanguageMap.put(user.Id, user.LanguageLocaleKey);
        }

        for (SObject sobj : records) {
            for (String fieldName : fieldNames) {
                String labelName = (String) sobj.get(fieldName);
                if (String.isEmpty(labelName))
                    continue;
                String labelValue = getLabelValue(
                    labelName,
                    useOwnerLanguage
                        ? userLanguageMap.get((Id) sobj.get('OwnerId'))
                        : UserInfo.getLanguage()
                );
                sobj.put(fieldName, labelValue);
            }
        }
    }

    /*public static void substituteParameters(List<SObject> records, Map<String, String> sentenceFieldParamsFieldMap){
        //retrieve param values:
        List<VT_D2_TranslateParameters.Parameter> params = new List<VT_D2_TranslateParameters.Parameter>();
        for(SObject sobj : records){
            for(String sentenceFieldName : sentenceFieldParamsFieldMap.keySet()){
                String paramsFieldName = sentenceFieldParamsFieldMap.get(sentenceFieldName);
                params.addAll(VT_D2_TranslateParameters.getParameters(sobj, sentenceFieldName, paramsFieldName));
            }
        }
        VT_D2_TranslateParameters.retrieveParamsAndUpdateTargetObjects(params);
    }*/

    public static Map<SObjectField, Map<String, String>> valueToLabelMap = new Map<SObjectField, Map<String, String>>();

    public static String getPickListLabel(SObjectField field, String value) {
        Map<String, String> translationMap = valueToLabelMap.get(field);
        if (translationMap == null) {
            translationMap = new Map<String, String>();
            for (PicklistEntry ple : field.getDescribe().getPicklistValues()) {
                translationMap.put(ple.getValue(), ple.getLabel());
            }
            valueToLabelMap.put(field, translationMap);
        }
        String label = translationMap.get(value);
        if (label != null)
            return label;
        return value;
    }

    public static String convertBrowserLanguage(List<String> browserLanguages) {
        List<String> languages = new List<String>();
        Map<String, List<String>> langGroupsMap = new Map<String, List<String>>();
        for (PicklistEntry ple : Translation__c.Language__c.getDescribe().getPicklistValues()) {
            List<String> langParts = ple.value.split('_');
            String langKey = langParts[0];
            String langDialect = langKey;
            if (langParts.size() > 0)
                langDialect = ple.value;
            List<String> dialects = langGroupsMap.get(langKey);
            if (dialects == null)
                dialects = new List<String>();
            dialects.add(langDialect);
            langGroupsMap.put(langKey, dialects);
            languages.add(ple.value);
        }
        System.debug(JSON.serializePretty(langGroupsMap));

        //iterate over browser langs:
        for (String browserLanguage : browserLanguages) {
            if (browserLanguage.contains('-')) {
                List<String> langParts = browserLanguage.split('-');
                String langKey = langParts[0].toLowerCase();
                String dialect = langKey + '_' + langParts[1].toUpperCase();
                List<String> dialects = langGroupsMap.get(langKey);
                if (dialects == null)
                    return null;
                if (dialects.contains(dialect)) {
                    return dialect;
                } else {
                    return dialects[0];
                }
            } else if (langGroupsMap.containsKey(browserLanguage)) {
                return langGroupsMap.get(browserLanguage)[0];
            }
        }
        return null;
    }

    public static String replaceParams(
        String source,
        String paramPrefix,
        Map<String, String> params
    ) {
        if (source == null)
            return null;
        String result = source;
        for (String param : params.keySet()) {
            String paramId = paramPrefix + param;
            String paramValue = params.get(param);

            if (paramValue == null)
                paramValue = '';
            if (param == 'StudyorProgramHeader') {
                if (paramValue == 'true')
                    paramValue = System.Label.Program_Header_PP;
                else
                    paramValue = System.Label.Study_Header_PP;
            }
            if (param == 'isEventorVisit') {
                if (paramValue == 'true')
                    paramValue = System.Label.Events_PP;
                else
                    paramValue = System.Label.Visits_PP;
            }

            if (param == 'isStudyorProgram') {
                if (paramValue == 'true')
                    paramValue = System.Label.Program_Header_PP;
                else
                    paramValue = System.Label.Study_PP;
            }
            if (param == 'studiesOrPrograms') {
                if (paramValue == 'true')
                    paramValue = System.Label.Programs_PP;
                else
                    paramValue = System.Label.Studies_PP;
            }

            result = result.replaceAll(paramId, paramValue);
        }
        return result;
    }

    private static Set<String> supportedLanguages;

    public static Set<String> getSupportedLanguageCodes() {
        if (supportedLanguages == null) {
            supportedLanguages = new Set<String>();
            List<PicklistEntry> picklistEntries = User.LanguageLocaleKey.getDescribe()
                .getPicklistValues();
            for (Schema.PicklistEntry picklistEntry : picklistEntries)
                if (picklistEntry.isActive())
                    supportedLanguages.add(picklistEntry.getValue());
        }
        return supportedLanguages;
    }

    public static Boolean isLanguageSupported(String langCode) {
        return getSupportedLanguageCodes().contains(langCode);
    }
}
