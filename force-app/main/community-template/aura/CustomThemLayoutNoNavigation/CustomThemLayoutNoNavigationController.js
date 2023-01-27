/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.initialize(component);

        if (communityService.isInitialized()) {
            component.set('v.communityName', communityService.getCurrentCommunityName());
            if (!communityService.isDummy())
                component.set('v.mode', communityService.getUserMode());
            if (
                communityService.isDummy() &&
                communityService.getCommunityName() === 'GSK_Community1'
            ) {
                component.set('v.isGSKGuestUser', true);
            }
            component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
            component.set('v.isInitialized', true);
            var rtl_language = $A.get('$Label.c.RTL_Languages');
            var paramLanguage = communityService.getUrlParameter('lanCode');
            component.set('v.isRTL', rtl_language.includes(paramLanguage));
            var RTL = rtl_language.includes(paramLanguage);
            if (!RTL) {
                component.set('v.isRTL', rtl_language.includes(communityService.getLanguage()));
                RTL = component.get('v.isRTL');
            }
            component.set('v.urlPathPrefix', communityService.getCommunityURLPathPrefix());
            component.set('v.currentMode', communityService.getCurrentCommunityMode());
        }
    },

    doGoHome: function () {
        sessionStorage.setItem('Cookies', 'Accepted');
        communityService.navigateToPage('');
    }
});
