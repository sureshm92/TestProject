/**
 * Created by Kryvolap on 03.09.2019.
 */
({
    doInit: function (component, event, helper) {
        if(!communityService.isInitialized()) return;
        var mode = communityService.getUserMode();
        component.set('v.isDelegate', communityService.isDelegate());
        component.set('v.userMode', mode);
        component.set('v.isInitialized', true);
    }
})