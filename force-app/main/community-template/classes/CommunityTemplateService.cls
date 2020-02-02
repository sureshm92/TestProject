/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityTemplateService {
    
    public static final String TEMPLATE_DEFAULT = 'Default';
    public static final Map<String, String> RESOURCES_URL_MAP = getResourcesURLMap();
    public static final Map<String, Network> NETWORKS_MAP = getNetworksMap();
    public static final Map<String, CommunityTemplate> TEMPLATES_MAP = getTemplatesMap();
    
    public static CommunityTemplate getTemplate(String templateName){
        if(templateName == null) templateName = '';
        CommunityTemplate template = TEMPLATES_MAP.get(templateName);
        if(template == null) template = TEMPLATES_MAP.get(TEMPLATE_DEFAULT);
        return template;
    }
    
    public static CommunityTemplate getDefaultTemplate(){
        return getTemplate(TEMPLATE_DEFAULT);
    }
    
    public static Map<String, CommunityTemplate> getTemplatesMap(){
        List<Community_Template__mdt> templates = [
                SELECT Id, Community_Name__c, Label,
                (SELECT Id, Label, Value__c FROM CommunityTemplate_Properties__r)
                FROM Community_Template__mdt
        ];
        Map<String, CommunityTemplate> templatesMap = new Map<String, CommunityTemplate>();
        Map<String, String> defaultProperties = new Map<String, String>();
        for(Community_Template__mdt template : templates){
            Map<String, String> propertiesMap = new Map<String, String>();
            propertiesMap.putAll(defaultProperties);
            for(CommunityTemplate_Property__mdt property : template.CommunityTemplate_Properties__r){
                propertiesMap.put(property.Label, replaceResourceParameter(property.Value__c));
            }
            templatesMap.put(template.Label, new CommunityTemplate(
                    propertiesMap,
                    getCommunityURL(template.Community_Name__c)
            ));
            if(template.Label == TEMPLATE_DEFAULT) defaultProperties = propertiesMap;
        }
        return templatesMap;
    }
    
    public static String getCommunityURL(String communityName){
        Network nw = NETWORKS_MAP.get(communityName);
        if(nw != null) {
            List<String> urlItems = Network.getLoginUrl(nw.Id).split('/');
            List<String> resURLItems = new List<String>{urlItems[0], urlItems[1], urlItems[2]};
            String url = String.join(resURLItems, '/');
            if(nw.UrlPathPrefix != null) url += '/' + nw.UrlPathPrefix;
            return url;
        }
        return null;
    }
    
    
    public static Map<String, Network> getNetworksMap(){
        List<Network> networks = [
                SELECT Id, Name, UrlPathPrefix
                FROM Network
        ];
        Map<String, Network> networksMap = new Map<String, Network>();
        for(Network network : networks) networksMap.put(network.Name, network);
        return networksMap;
    }
    
    public static Map<String, String> getResourcesURLMap() {
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
    
    public static String replaceResourceParameter(String sourceString){
        String resStr = sourceString;
        for(String resourceName : RESOURCES_URL_MAP.keySet()){
            resStr = resStr.replace(resourceName, RESOURCES_URL_MAP.get(resourceName));
        }
        return resStr;
    }



}