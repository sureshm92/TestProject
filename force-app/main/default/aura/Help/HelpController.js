({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        component.set('v.isInitialized', true);
    },

})