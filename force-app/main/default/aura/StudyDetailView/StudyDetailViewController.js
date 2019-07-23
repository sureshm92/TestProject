({
    doInit: function (component, event, helper) {
        if(communityService.isInitialized()){
            component.set('v.userMode', communityService.getUserMode());
        }
    }
})