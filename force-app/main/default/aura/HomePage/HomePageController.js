/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        debugger;
        console.log('DEBUG>>USER MODE IS '+communityService.getUserMode);
        debugger;
        component.set('v.userMode', communityService.getUserMode());
        component.set('v.initialized', true);
        component.find('spinner').hide();
    }
})