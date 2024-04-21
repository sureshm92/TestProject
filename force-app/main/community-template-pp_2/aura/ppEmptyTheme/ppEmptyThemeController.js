({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) {
            communityService.initialize(component);
            component.set('v.initialized', true);
        }
    }
});
