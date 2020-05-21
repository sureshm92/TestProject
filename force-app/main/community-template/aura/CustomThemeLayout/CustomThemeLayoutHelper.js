/**
 * Created by Leonid Bartenev
 */
({
    init: function (component) {
        component.set('v.allModes', communityService.getAllUserModes());
        component.set('v.currentMode', communityService.getCurrentCommunityMode());
        component.set('v.showModeSwitcher', !(communityService.getAllUserModes().length === 1 && communityService.getAllUserModes()[0].subModes.length <= 1));
        component.set('v.isArabic', communityService.getLanguage() === 'ar' );
        component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
        component.set('v.isInitialized', true);
    }
});