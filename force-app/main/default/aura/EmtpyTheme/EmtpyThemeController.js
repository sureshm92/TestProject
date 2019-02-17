/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()){
            debugger;
            communityService.initialize(component);
        }
    }
})