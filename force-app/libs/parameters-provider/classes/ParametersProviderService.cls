/**
 * Created by Leonid Bartenev
 */

public without sharing class ParametersProviderService {
    
    private static Map<String, Parameters_Provider__mdt> ppByNameMap = new Map<String, Parameters_Provider__mdt>();
    static {
        List<Parameters_Provider__mdt> ppList = [
                SELECT Id, DeveloperName, Parameters__c, Source_Object_Type__c
                FROM Parameters_Provider__mdt
        ];
        for(Parameters_Provider__mdt pp: ppList) ppByNameMap.put(pp.DeveloperName, pp);
    }
    
    public static Parameters_Provider__mdt getParametersProvider(String developerName){
        return ppByNameMap.get(developerName);
    }
    
    public static List<SObject> queryRecords(List<Id> recordIds, String providerName){
        List<SObject> resultList = new List<SObject>();
        Map<String, String> paramsMap = getParamsMap(providerName);
        SObjectType sObjectType = getSObjectType(providerName);
        if(recordIds == null || recordIds.size() == 0 || paramsMap.size() == 0 || sObjectType == null) return resultList;
        Set<String> values = new Set<String>(paramsMap.values());
        return DatabaseService.query(
                new List<String>(values),
                sObjectType,
                DatabaseService.fieldInValues('Id', recordIds)
        );
    }
    
    public static Map<String, String> getParamsMap(String providerName) {
        Map<String, String> resMap = new Map<String, String>();
        Parameters_Provider__mdt pp = getParametersProvider(providerName);
        if(pp == null || String.isEmpty(pp.Parameters__c))  return resMap;
        List<String> lines = pp.Parameters__c.split('\n');
        for (String line : lines) {
            List<String> lineParts = line.split('=');
            String paramName = lineParts[0].trim();
            String paramValue;
            if (lineParts.size() > 1) paramValue = lineParts[1].trim();
            resMap.put(paramName, paramValue);
        }
        return resMap;
    }
    
    public static SObjectType getSObjectType(String providerName){
        Parameters_Provider__mdt pp = getParametersProvider(providerName);
        if(pp == null) return null;
        return Schema.getGlobalDescribe().get(pp.Source_Object_Type__c);
    }
    
    public static String substituteMergeFields(String sourceString, String providerName, SObject sourceObject, String language){
        if(language == null) language = UserInfo.getLanguage();
        Map<String, String> paramsMap = getParamsMap(providerName);
        Map<String, String> valuesMap = new Map<String, String>();
        for (String paramName : paramsMap.keySet()) {
            String fieldPath = paramsMap.get(paramName);
            Object value = SObjectHelper.getSObjectFieldValue(sourceObject, fieldPath);
            String valueStr;
            if (value instanceof Date) {
                valueStr = UserService.formatDate((Date) value, language);
            } else if (value instanceof Datetime) {
                valueStr = UserService.formatDateTime((Date) value, language);
            } else {
                valueStr = (value != null ? value : '') + '';
            }
            valuesMap.put(paramName, valueStr);
        }
        if (sourceString == null) return null;
        String resultValue = sourceString;
        for (String parameterName : valuesMap.keySet()) {
            resultValue = resultValue.replace('##' + parameterName, valuesMap.get(parameterName));
        }
        return resultValue;
    }
    
}