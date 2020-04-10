/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        component.set('v.userMode', communityService.getUserMode());
        if(!communityService.isDummy()) {
            component.set('v.initialized', true);
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
        component.find('spinner').hide();
    }
});