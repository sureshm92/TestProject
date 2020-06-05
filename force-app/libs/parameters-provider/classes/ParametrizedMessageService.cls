/**
 * Created by Leonid Bartenev
 */

public without sharing class ParametrizedMessageService {
    
    public class ParametrizedMessage{
    
        private String sourceMessage;
        private String paramProviderName;
        private Id whatId;
        private String language;
        private String resultMessage;
        private SObject sobj;
        
        public ParametrizedMessage(String sourceMessage, Id whatId, String paramProviderName, String language){
            this.sourceMessage = TranslateHelper.getLabelValue(sourceMessage, language);
            this.whatId = whatId;
            this.paramProviderName = paramProviderName;
            this.language = language;
        }
        
        public String getMessage(){
            if (resultMessage == null) resultMessage = sourceMessage;
            return resultMessage;
        }
        
        public void setSObject(SObject sobj){
            resultMessage = null;
            if(sobj == null) return;
            if (sourceMessage == null) return ;
            Map<String, String> paramsMap = ParametersProviderService.getParamsMap(paramProviderName);
            Map<String, String> valuesMap = new Map<String, String>();
            for (String paramName : paramsMap.keySet()) {
                String fieldPath = paramsMap.get(paramName);
                Object value = SObjectHelper.getSObjectFieldValue(sobj, fieldPath);
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
            resultMessage = sourceMessage;
            for (String parameterName : valuesMap.keySet()) {
                resultMessage = resultMessage.replace('##' + parameterName, valuesMap.get(parameterName));
            }
        }
    }
    
    private Map<String, ParametrizedMessage> messagesMap = new Map<String, ParametrizedMessage>();
    private Map<Id, SObject> allSObjects = new Map<Id, SObject>();
    
    public void addMessage(String key, String sourceMessage, Id whatId, String paramProviderName, String language){
        messagesMap.put(key, new ParametrizedMessage(sourceMessage, whatId, paramProviderName, language));
    }
    
    public void processMessages(){
        //group by provider name
        Map<String, List<Id>> idsByProviderMap =  new Map<String, List<Id>>();
        for(ParametrizedMessage pm : messagesMap.values()){
            if(pm.paramProviderName == null || pm.whatId == null) continue;
            List<Id> whatIds = idsByProviderMap.get(pm.paramProviderName);
            if(whatIds == null) whatIds = new List<Id>();
            whatIds.add(pm.whatId);
            idsByProviderMap.put(pm.paramProviderName, whatIds);
        }
        //query records for all grouped whatIds
        for(String providerName : idsByProviderMap.keySet()){
            List<Id> whatIds = idsByProviderMap.get(providerName);
            List<SObject> records = ParametersProviderService.queryRecords(whatIds, providerName);
            for(SObject sobj : records) allSObjects.put(sobj.Id, sobj);
        }
        //group whatIds by language
        Map<String, List<SObject>> sObjectsByLanguageMap = new Map<String, List<SObject>>();
        for(ParametrizedMessage pm : messagesMap.values()){
            if(pm.whatId == null || pm.language == null) continue;
            List<SObject> sObjectList = sObjectsByLanguageMap.get(pm.whatId);
            if(sObjectList == null) sObjectList = new List<SObject>();
            SObject sObj = allSObjects.get(pm.whatId);
            if(sObj != null) sObjectList.add(sObj);
            sObjectsByLanguageMap.put(pm.language, sObjectList);
        }
        //translate sObjects
        for(String language : sObjectsByLanguageMap.keySet()){
            List<SObject> sObjects = sObjectsByLanguageMap.get(language);
            TranslateHelper.translate(sObjects, language);
        }
        //update messages
        for(ParametrizedMessage pm : messagesMap.values()){
            SObject sobj = allSObjects.get(pm.whatId);
            pm.setSObject(sobj);
        }
    }
    
    public String getMessage(String key){
        ParametrizedMessage pm = messagesMap.get(key);
        if(pm == null) return null;
        return  pm.getMessage();
    }


}