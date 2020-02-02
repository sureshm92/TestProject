/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityTemplate {
    
    @AuraEnabled public Map<String, String> properties;
    @AuraEnabled public String communityURL;
    @AuraEnabled public String currentCommunityURL;
    @AuraEnabled public Boolean needRedirect;
    
    public CommunityTemplate(Map<String, String> properties, String communityURL){
        this.properties = properties;
        this.communityURL = communityURL;
        this.currentCommunityURL = Site.getBaseUrl() + Site.getPathPrefix();
        this.needRedirect = communityURL != null && !communityURL.containsIgnoreCase(currentCommunityURL);
    }

}