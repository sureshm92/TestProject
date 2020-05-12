({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.isInitialized', true);
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    }
});