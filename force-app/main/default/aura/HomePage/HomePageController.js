/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        component.set('v.userMode', communityService.getUserMode().userMode);
        component.set('v.initialized', true);
        component.find('spinner').hide();
    }
})