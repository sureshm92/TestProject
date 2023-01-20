({
    doInit: function (component, event, helper) {
        communityService.executeAction(
            component,
            'getSwitcherInitData',
            null,
            function (returnValue) {
                const userData = JSON.parse(returnValue);
                component.set('v.user', userData.user);
                component.set('v.hasProfilePic', userData.hasProfilePic);
                component.set('v.communityModes', userData.communityModes);
                component.set(
                    'v.initialCommunityModes',
                    JSON.parse(JSON.stringify(component.get('v.communityModes')))
                );
                component.set('v.currentMode', communityService.getCurrentCommunityMode());
            }
        );
    }
});
