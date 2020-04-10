/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.initialize(component);

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