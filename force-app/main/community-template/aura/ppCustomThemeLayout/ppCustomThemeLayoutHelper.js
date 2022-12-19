({
    init: function (component) {
        let isDummy = communityService.isDummy();
        var rtl_language = $A.get('$Label.c.RTL_Languages');
        component.set('v.isDummy', isDummy);
        if (!isDummy) {
            component.set(
                'v.showModeSwitcher',
                !(
                    communityService.getAllUserModes().length === 1 &&
                    communityService.getAllUserModes()[0].subModes.length <= 1
                )
            );
        }
        component.set('v.currentMode', communityService.getCurrentCommunityMode());
        component.set('v.isRTL', rtl_language.includes(communityService.getLanguage()));
        component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
        component.set('v.urlPathPrefix', communityService.getCommunityURLPathPrefix());
        component.set('v.isMobileApp', communityService.isMobileSDK());
        component.set('v.isInitialized', true);
    }
});