/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        component.set('v.userMode', communityService.getUserMode());
        component.set('v.communityName', communityService.getCurrentCommunityName());
        component.set('v.currentMode', communityService.getCurrentCommunityMode());

        if (!communityService.isDummy()) {
            component.set('v.initialized', true);
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
        component.find('spinner').hide();
    }
});
