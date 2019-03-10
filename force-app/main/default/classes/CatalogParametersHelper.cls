/**
 * Created by Leonid Bartenev
 */

public class CatalogParametersHelper {

    public static String getErrorInParameters(SObjectType sObjectType, String parameters){
        if(String.isEmpty(parameters)) return null;
        Map<String, String> paramsMap = getParamsMap(parameters);
        for(String paramName : paramsMap.keySet()){
            String paramValue = paramsMap.get(paramName);
            if(paramValue == null) return 'Parameter: ' + paramName + '; Field path can not be empty';
            if(!SObjectHelper.hasField(sObjectType, paramValue)) return 'Parameter: ' + paramName + '; Wrong field path: ' + paramValue;
        }
        return null;
    }
    
    public static Map<String, String> getParamsMap(String parameters){
        List<String> lines = parameters.split('\n');
        Map<String, String> resMap = new Map<String, String>();
        for(String line : lines){
            List<String> lineParts = line.split('=');
            String paramName = lineParts[0].trim();
            String paramValue;
            if(lineParts.size() > 1) paramValue = lineParts[1].trim();
            resMap.put(paramName, paramValue);
        }
        return resMap;
    }
    
    public static Map<String, String> getParamsValueMap(SObject sObj, String parameters){
        Map<String, String> resMap = new Map<String, String>();
        Map<String, String> cardParametersMap = CatalogParametersHelper.getParamsMap(parameters);
        for(String paramName: cardParametersMap.keySet()) {
            String fieldPath = cardParametersMap.get(paramName);
            String value = (String) SObjectHelper.getSObjectFieldValue(sObj, fieldPath);
            if(fieldPath != null && value != null) resMap.put(paramName, value);
        }
        return resMap;
    }
    
    public static List<SObject> queryObjects(String objectType, Set<String> fields, Set<Id> recIds){
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
        if(String.isEmpty(labelName)) return labelName;
        String resultValue = TranslateHelper.getLabelValue(labelName);
        for(String parameterName: parameters.keySet()) {
            resultValue = resultValue.replace('##' + parameterName, parameters.get(parameterName));
        }
        return resultValue;
    }

}