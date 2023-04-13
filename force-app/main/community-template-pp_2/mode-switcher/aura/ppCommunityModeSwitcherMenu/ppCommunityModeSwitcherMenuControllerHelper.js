({
    doInit: function (component, event, helper) {
        console.log('Switcher Helper doInit');
        communityService.executeAction(
            component,
            'getSwitcherInitData',
            null,
            function (returnValue) {
                const userData = JSON.parse(returnValue);
                component.set('v.user', userData.user);
                component.set('v.hasProfilePic', userData.hasProfilePic);
                component.set('v.communityModes', userData.communityModes);
                console.log('Comm mode' + JSON.stringify(userData.communityModes));
                component.set(
                    'v.initialCommunityModes',
                    JSON.parse(JSON.stringify(component.get('v.communityModes')))
                );
                component.set('v.currentMode', communityService.getCurrentCommunityMode());
            }
        );
    }
});
