/**
 * Created by Leonid Bartenev
 */

public without sharing class CommunityTemplate {

    @AuraEnabled public Map<String, String> properties;
    @AuraEnabled public String currentCommunityURL;
    @AuraEnabled public String redirectURL;
    @AuraEnabled public Boolean needRedirect;
    @AuraEnabled public String communityName;

    public CommunityTemplate(Map<String, String> properties, String communityName, String communityURL) {
        this.communityName = communityName;
        this.properties = properties;
        this.currentCommunityURL = Site.getBaseUrl();
        this.redirectURL = communityURL;
        this.needRedirect = communityName != UserContext.getCurrentCommunityName();
    }

}