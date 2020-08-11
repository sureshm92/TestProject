/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityTemplate {

    @AuraEnabled public Map<String, String> properties;
    @AuraEnabled public String templateName;
    @AuraEnabled public String currentCommunityURL;
    @AuraEnabled public String redirectURL;
    @AuraEnabled public String pathPrefix;
    @AuraEnabled public Boolean needRedirect;
    @AuraEnabled public String communityName;
    @AuraEnabled public String shortCommunityName;
    @AuraEnabled public String permissionSet;

    public CommunityTemplate(Community_Template__mdt templateMdt, Map<String, String> properties) {
        this.communityName = templateMdt.Community_Name__c;
        this.permissionSet = templateMdt.Permission_Set_Developer_Name__c;
        this.properties = properties;
        this.templateName = templateMdt.DeveloperName;
        this.currentCommunityURL = Site.getBaseUrl();
        this.redirectURL = CommunityTemplateService.getCommunityURL(templateMdt.Community_Name__c);
        this.pathPrefix = properties.get(CommunityTemplateService.PROPERTY_PATH_PREFIX);
        this.needRedirect = communityName != UserContext.getCurrentCommunityName();
        this.shortCommunityName = templateMdt.ShortCommunityName__c;
    }

}