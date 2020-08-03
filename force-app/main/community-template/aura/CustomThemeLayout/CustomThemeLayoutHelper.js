/**
 * Created by Leonid Bartenev
 */
({
    init: function (component) {
        let isDummy = communityService.isDummy();
        component.set('v.isDummy', isDummy);
        if(!isDummy) {
            component.set('v.allModes', communityService.getAllUserModes());
            component.set('v.showModeSwitcher', !(communityService.getAllUserModes().length === 1 && communityService.getAllUserModes()[0].subModes.length <= 1));
        }
        component.set('v.currentMode', communityService.getCurrentCommunityMode());
        component.set('v.logoURL', communityService.getTemplateProperty('CommunityLogo'));
        communityService.executeAction(component, 'isCurrentSessionMobileApp', null,
            function (returnValue) {
                component.set('v.isMobileApp', returnValue);
            });
        component.set('v.isInitialized', true);
    }
});