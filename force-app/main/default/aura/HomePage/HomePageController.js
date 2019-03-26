/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;

        component.set('v.userMode', communityService.getUserMode());
        component.set('v.initialized', true);
        component.find('spinner').hide();
    }
})