/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.set('v.subDomain', communityService.getSubDomain());
    }
})