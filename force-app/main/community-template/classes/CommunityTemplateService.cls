/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityTemplateService {
    
    public static final String TEMPLATE_DEFAULT = 'Default';
    
    public static Map<String, String> getTemplateProperties(Id peId){
        System.debug('XXX_PE ID: ' + peId);
        Community_Template_Selector__c selector = new Community_Template_Selector__c();
        if(peId != null){
            selector = new Community_Template_Selector__c(Participant_Enrollment__c = peId);
            insert selector;
            selector = [SELECT Template_Selector_Formula__c FROM Community_Template_Selector__c WHERE Id =: selector.Id];
        }
        List<String> templateNames = new List<String>{'Default'};
        String templateName = selector.Template_Selector_Formula__c;
        if(!String.isEmpty(templateName)) templateNames.add(selector.Template_Selector_Formula__c);
        List<CommunityTemplate_Property__mdt> templatePropertis = [
                SELECT Id, Value__c, Label, Community_Template__r.Label
                FROM CommunityTemplate_Property__mdt
                WHERE Community_Template__r.Label IN: templateNames];
        Map<String, String> resMap = new Map<String, String>();
        //Set default properties
        for(CommunityTemplate_Property__mdt property : templatePropertis){
            if(property.Community_Template__r.Label == 'Default'){
                resMap.put(property.Label, property.Value__c);
            }
        }
        //Set specified properties:
        for(CommunityTemplate_Property__mdt property : templatePropertis){
            if(!String.isEmpty(templateName) && property.Community_Template__r.Label == templateName){
                resMap.put(property.Label, property.Value__c);
            }
        }
        Map<String, String> resourcesURLMap = getResourceURLMap();
        for(String resourceName : resourcesURLMap.keySet()){
            for(String propertyName : resMap.keySet()){
                String value = resMap.get(propertyName);
                value = value.replace(resourceName, resourcesURLMap.get(resourceName));
                resMap.put(propertyName, value);
            }
        }
        if(selector.Id != null) delete selector;
        return resMap;
    }
    
    public static Map<String, String> getResourceURLMap() {
        List<StaticResource> resourceList = [
                SELECT Name, NamespacePrefix, SystemModStamp
                FROM StaticResource];
        Map<String, String> resourcesMap = new Map<String, String>();
        for(StaticResource resource : resourceList){
            String namespace = resource.NamespacePrefix;
            String resourceURL = '/resource/' + resource.SystemModStamp.getTime() +
                    '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resource.Name;
            resourcesMap.put('$Resource/' + resource.Name, resourceURL);
        }
        return resourcesMap;
    }

}