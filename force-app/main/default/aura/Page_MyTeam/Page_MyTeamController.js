/**
 * Created by Kryvolap on 03.09.2019.
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if (!communityService.isDummy()) {
            component.set('v.isDelegate', communityService.isDelegate());
            component.set('v.communityName', communityService.getCurrentCommunityName());
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.isInitialized', true);
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});