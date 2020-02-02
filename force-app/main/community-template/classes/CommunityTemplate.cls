/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityTemplate {
    
    @AuraEnabled public Map<String, String> properties;
    @AuraEnabled public String currentCommunityURL;
    @AuraEnabled public String redirectURL;
    @AuraEnabled public Boolean needRedirect;
    
    public CommunityTemplate(Map<String, String> properties, CommunityTemplateService.URLInfo urlInfo){
        this.properties = properties;
        this.currentCommunityURL = Site.getBaseUrl();
        this.redirectURL = urlInfo != null ? urlInfo.getFullURL() : null ;
        this.needRedirect = urlInfo != null && currentCommunityURL != urlInfo.getFullURL();
    }

}