/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) {
            communityService.initialize(component);
            component.set('v.initialized', true);
        }
        if (communityService.isInitialized()) {
            component.set('v.communityName', communityService.getCurrentCommunityName());
        }
    }
});
