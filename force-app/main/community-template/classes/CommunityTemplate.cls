/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityTemplate {
    
    @AuraEnabled public Map<String, String> properties;
    @AuraEnabled public String currentCommunityURL;
    @AuraEnabled public String redirectURL;
    @AuraEnabled public Boolean needRedirect;
    
    public CommunityTemplate(Map<String, String> properties, String communityURL){
        this.properties = properties;
        this.currentCommunityURL = Site.getBaseUrl();
        this.redirectURL = communityURL != null ? communityURL : null ;
        this.needRedirect = communityURL != null && currentCommunityURL != communityURL;
    }

}