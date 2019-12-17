/**
 * Created by Leonid Bartenev
 */

public class CatalogParametersHelper {

    public class ParametersProviderException extends Exception {
    }
//    private static Map<String, Parameters_Provider__mdt> ppByNameMap = new Map<String, Parameters_Provider__mdt>();
//    static {
//        List<Parameters_Provider__mdt> ppList = [
//                SELECT Id, DeveloperName, Parameters__c, Source_Object_Type__c
//                FROM Parameters_Provider__mdt
//        ];
//        for(Parameters_Provider__mdt pp: ppList) ppByNameMap.put(pp.DeveloperName, pp);
//    }

    public static String getErrorInParameters(SObjectType sObjectType, String parameters) {
        if (String.isEmpty(parameters)) return null;
        Map<String, String> paramsMap = getParamsMap(parameters);
        for (String paramName : paramsMap.keySet()) {
            String paramValue = paramsMap.get(paramName);
            if (paramValue == null) return 'Parameter: ' + paramName + '; Field path can not be empty';
            if (!SObjectHelper.hasField(sObjectType, paramValue)) return 'Parameter: ' + paramName + '; Wrong field path: ' + paramValue;
        }
        return null;
    }

    public static Map<String, String> getParamsMap(String parameters) {
        List<String> lines = parameters.split('\n');
        Map<String, String> resMap = new Map<String, String>();
        for (String line : lines) {
            List<String> lineParts = line.split('=');
            String paramName = lineParts[0].trim();
            String paramValue;
            if (lineParts.size() > 1) paramValue = lineParts[1].trim();
            resMap.put(paramName, paramValue);
        }
        return resMap;
    }

    public static Map<String, String> getParamsValueMap(String sourceId, Parameters_Provider__mdt pp, String language) {
        Map<String, String> paramsMap = getParamsMap(pp.Parameters__c);
        Set<String> fields = new Set<String>(paramsMap.values());
        List<SObject> sObjects = queryObjects(pp.Source_Object_Type__c, fields, new Set<Id>{
                sourceId
        });
        TranslateHelper.translate(sObjects, language);
        Map<String, String> resultMap = new Map<String, String>();
        for (String paramName : paramsMap.keySet()) {
            String fieldPath = paramsMap.get(paramName);
            Object value = SObjectHelper.getSObjectFieldValue(sObjects[0], fieldPath);
            String valueStr;
            if (value instanceof Date) {
                valueStr = UserService.formatDate((Date) value, language);
            } else if (value instanceof Datetime) {
                valueStr = UserService.formatDateTime((Date) value, language);
            } else {
                valueStr = (value != null ? value : '') + '';
            }
            resultMap.put(paramName, valueStr);
        }
        return resultMap;
    }

    public static Map<String, String> getParamsValueMap(SObject sObj, String parameters) {
        Map<String, String> resMap = new Map<String, String>();
        Map<String, String> cardParametersMap = CatalogParametersHelper.getParamsMap(parameters);
        for (String paramName : cardParametersMap.keySet()) {
            String fieldPath = cardParametersMap.get(paramName);
            String value = (String) SObjectHelper.getSObjectFieldValue(sObj, fieldPath);
            if (fieldPath != null && value != null) resMap.put(paramName, value);
        }
        return resMap;
    }

    public static List<SObject> queryObjects(String objectType, Set<String> fields, Set<Id> recIds) {
        List<String> fieldsList = new List<String>();
        fieldsList.addAll(fields);
        List<Id> idsList = new List<Id>();
        idsList.addAll(recIds);
        String query = 'SELECT ' + String.join(fieldsList, ',') + ' FROM ' + objectType
                + ' WHERE Id IN (\'' + String.join(idsList, '\',\'') +
                '\')';
        System.debug('RESULT QUERY: ' + query);
        List<SObject> records = Database.query(query);
        TranslateHelper.translate(records);
        return records;
    }

    public static String prepareLabel(String labelName, Map<String, String> parameters) {
        return prepareLabel(labelName, parameters, UserInfo.getLanguage());
    }

    public static String prepareLabel(String labelName, Map<String, String> parameters, String language) {
        if (String.isEmpty(labelName)) return labelName;
        return prepareMergeFields(TranslateHelper.getLabelValue(labelName, language), parameters);
    }

//    public static String prepareLabel(String labelName, Id whatId, String paramProviderName, String language) {
//        Parameters_Provider__mdt pp = ppByNameMap.get(paramProviderName);
//
//        return prepareLabel();
//    }

    public static String prepareMergeFields(String sourceString, Map<String, String> parameters) {
        if (sourceString == null) return null;
        String resultValue = sourceString;
        for (String parameterName : parameters.keySet()) {
            resultValue = resultValue.replace('##' + parameterName, parameters.get(parameterName));
        }
        return resultValue;
    }

    public static String prepareMergeFields(String sourceString, Id sourceId, String providerDeveloperName) {
        Parameters_Provider__mdt parametersProvider = getParametersProviderMetadata(providerDeveloperName);
        Map<String, String> paramsMap = getParamsValueMap(sourceId, parametersProvider, UserInfo.getLanguage());
        return prepareMergeFields(sourceString, paramsMap);
    }


    public static Parameters_Provider__mdt getParametersProviderMetadata(String providerDeveloperName) {
        List<Parameters_Provider__mdt> parametersProviders = [
                SELECT Id, DeveloperName, Parameters__c, Source_Object_Type__c
                FROM Parameters_Provider__mdt
                WHERE DeveloperName = :providerDeveloperName
        ];
        if (parametersProviders.size() == 0) throw new ParametersProviderException('Parameters Provider "' + providerDeveloperName + '" not found');
        return parametersProviders[0];
    }

    public static void validate() {
        List<Parameters_Provider__mdt> parametersProviders = [
                SELECT Id, DeveloperName, Parameters__c, Source_Object_Type__c
                FROM Parameters_Provider__mdt
        ];
        for (Parameters_Provider__mdt pp : parametersProviders) {
            SObjectType sObjectType = Schema.getGlobalDescribe().get(pp.Source_Object_Type__c);
            if (sObjectType == null) {
                throw new ParametersProviderException('Wrong parameters provider: ' + pp.DeveloperName + '.' +
                        ' SObject "' + pp.Source_Object_Type__c + '" not exists');
            }
            String errorMessage = getErrorInParameters(sObjectType, pp.Parameters__c);
            if (errorMessage != null) {
                throw new ParametersProviderException('Wrong parameters provider: ' + pp.DeveloperName + '.' +
                        ' Error in parameters: ' + errorMessage);

            }
        }
    }

}