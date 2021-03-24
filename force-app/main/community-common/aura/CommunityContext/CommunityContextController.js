/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        component.set('v.isRTL', rtl_language.includes(communityService.getLanguage()));
        component.set('v.language', communityService.getLanguage());
        component.set('v.isMobileApp', communityService.isMobileSDK());
        // component.set('v.communityName', communityService.getCurrentCommunityName());
    }
});
