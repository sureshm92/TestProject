/**
 * Created by Leonid Bartenev
 */

public without sharing class ParametersProviderService {
    private static Map<String, Parameters_Provider__mdt> ppByNameMap = new Map<String, Parameters_Provider__mdt>();
    static {
        List<Parameters_Provider__mdt> ppList = [
            SELECT
                Id,
                DeveloperName,
                Parameters__c,
                Alternate_Parameter_Source__c,
                Source_Object_Type__c
            FROM Parameters_Provider__mdt
        ];
        for (Parameters_Provider__mdt pp : ppList)
            ppByNameMap.put(pp.DeveloperName, pp);
    }

    public static Parameters_Provider__mdt getParametersProvider(String developerName) {
        return ppByNameMap.get(developerName);
    }

    public static List<SObject> queryRecords(List<Id> recordIds, String providerName) {
        List<SObject> resultList = new List<SObject>();
        Parameters parameters = getParamsMap(providerName);
        Map<String, String> paramsMap = parameters.parametersMap;
        Map<String, String> alternateParamsMap = parameters.parametersAlternateSourceMap;
        SObjectType sObjectType = getSObjectType(providerName);
        if (
            recordIds == null ||
            recordIds.size() == 0 ||
            paramsMap.size() == 0 ||
            sObjectType == null
        )
            return resultList;
        Set<String> values = new Set<String>(paramsMap.values());
        values.addAll(alternateParamsMap.values());
        return DatabaseService.query(
            new List<String>(values),
            sObjectType,
            DatabaseService.fieldInValues('Id', recordIds)
        );
    }

    public static Parameters getParamsMap(String providerName) {
        Map<String, String> parametersMap = new Map<String, String>();
        Map<String, String> parametersAlternateSourceMap = new Map<String, String>();
        Parameters parameters = new Parameters();
        parameters.parametersMap = parametersMap;
        parameters.parametersAlternateSourceMap = parametersAlternateSourceMap;
        Parameters_Provider__mdt pp = getParametersProvider(providerName);
        if (pp == null || String.isEmpty(pp.Parameters__c))
            return parameters;
        List<String> lines = pp.Parameters__c.split('\n');
        List<String> linesforaltparams = new List<String>();
        if (!(pp == null || String.isEmpty(pp.Alternate_Parameter_Source__c))) {
            linesforaltparams = pp.Alternate_Parameter_Source__c.split('\n');
        }
        parameters.parametersMap = getParameterMapFromString(lines);
        parameters.parametersAlternateSourceMap = getParameterMapFromString(linesforaltparams);
        return parameters;
    }

    private static Map<String, String> getParameterMapFromString(List<String> lines) {
        Map<String, String> parametersMap = new Map<String, String>();
        for (String line : lines) {
            List<String> lineParts = line.split('=');
            String paramName = lineParts[0].trim();
            String paramValue;
            if (lineParts.size() > 1)
                paramValue = lineParts[1].trim();
            parametersMap.put(paramName, paramValue);
        }
        return parametersMap;
    }

    public class Parameters {
        public Map<String, String> parametersMap;
        public Map<String, String> parametersAlternateSourceMap;
    }
    public static SObjectType getSObjectType(String providerName) {
        Parameters_Provider__mdt pp = getParametersProvider(providerName);
        if (pp == null)
            return null;
        return Schema.getGlobalDescribe().get(pp.Source_Object_Type__c);
    }

    public static Map<String, String> getValueMap(
        String providerName,
        SObject sourceObject,
        String language
    ) {
        Map<String, String> valueByParam = new Map<String, String>();
        String userLanguage = String.isNotEmpty(language) ? language : UserInfo.getLanguage();
        User userObj;
        Parameters parameters = getParamsMap(providerName);
        Map<String, String> paramsMap = parameters.parametersMap;
        Map<String, String> alternateParamsMap = parameters.parametersAlternateSourceMap;
        Map<String, Id> paramAndContactId = new Map<String, Id>();
        Map<Id, String> ContactIdAndValue = new Map<Id, String>();
        for (String paramName : alternateParamsMap.keySet()) {
            String fieldPath = alternateParamsMap.get(paramName);
            Object value = SObjectHelper.getSObjectFieldValue(sourceObject, fieldPath);
            if (value instanceof Id) {
                paramAndContactId.put(paramName, String.valueOf(value));
            }
        }

        for (String paramName : paramsMap.keySet()) {
            String fieldPath = paramsMap.get(paramName);
            Object value = SObjectHelper.getSObjectFieldValue(sourceObject, fieldPath);
            if (paramsMap.get('ContactID') != null) {
                Object contactIdValue = SObjectHelper.getSObjectFieldValue(
                    sourceObject,
                    paramsMap.get('ContactID')
                );
                if (UserService.contactIDvalue != null) {
                    userObj = [
                        SELECT Id, LocaleSidKey, TimeZoneSidKey
                        FROM User
                        WHERE ContactId = :UserService.contactIDvalue + ''
                    ];
                } else {
                    userObj = [
                        SELECT Id, LocaleSidKey, TimeZoneSidKey
                        FROM User
                        WHERE ContactId = :contactIdValue + ''
                    ];
                }
            }
            String valueStr;
            if (value instanceof Date) {
                valueStr = UserService.formatDate((Date) value, userLanguage);
            } else if (value instanceof Datetime) {
                if (userObj == null) {
                    valueStr = UserService.formatDateTime((Datetime) value, userLanguage);
                } else {
                    valueStr = UserService.formatDateTimebyZone(
                        (Datetime) value,
                        userObj.LocaleSidKey,
                        userObj.TimeZoneSidKey
                    );
                }
            } else {
                valueStr = (value != null ? value : '') + '';
            }
            if (paramName == 'Taskdate') {
                if (valueStr == '') {
                    valueStr = System.Label.Not_Available;
                }
            }
            /**PEH-9758*/
            if (paramName == 'TaskOnlydate') {
                if (valueStr == '') {
                    valueStr = System.Label.Not_Available;
                } else {
                    if (value instanceof Datetime) {
                        DateTime tempDateTime = (DateTime) value;
                        valueStr = UserService.formatDatebyLocale(tempDateTime.date(), language);
                    } else if (value instanceof Date) {
                        valueStr = UserService.formatDatebyLocale((Date) value, language);
                    }
                }
            }
            valueByParam.put(paramName, valueStr);
        }

        if (!paramAndContactId.isEmpty()) {
            for (Participant__c participant : [
                SELECT Id, Contact__c, Salutation__c, Full_Name__c
                FROM Participant__c
                WHERE Contact__c IN :paramAndContactId.values()
            ]) {
                ContactIdAndValue.put(
                    participant.Contact__c,
                    (participant.Salutation__c == null ? '' : participant.Salutation__c + ' ') +
                    participant.Full_Name__c
                );
            }
            for (String paramName : paramAndContactId.keySet()) {
                Id contactId = paramAndContactId.get(paramName);
                if (ContactIdAndValue.containsKey(contactId)) {
                    valueByParam.put(paramName, ContactIdAndValue.get(contactId));
                }
            }
        }
        return valueByParam;
    }

    public static String substituteMergeFields(
        String sourceString,
        String providerName,
        SObject sourceObject,
        String language
    ) {
        if (sourceString == null)
            return null;
        String resultValue = sourceString;

        Map<String, String> valuesMap = getValueMap(providerName, sourceObject, language);
        for (String parameterName : valuesMap.keySet()) {
            resultValue = resultValue.replace('##' + parameterName, valuesMap.get(parameterName));
        }
        return resultValue;
    }
}
