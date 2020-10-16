/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.initialize(component);
        var rtl_language = $A.get("$Label.c.RTL_Languages");
        component.set('v.isRTL', rtl_language.includes(communityService.getLanguage()));
        if(communityService.isInitialized()) {
            if(!communityService.isDummy()) component.set('v.mode', communityService.getUserMode());
            component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
            component.set('v.isInitialized', true);
        }
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    }
});