/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.initialize(component);

        if (communityService.isInitialized()) {
            if (!communityService.isDummy())
                component.set('v.mode', communityService.getUserMode());
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
        }
    },

    doGoHome: function () {
        communityService.navigateToPage('');
    }
});
