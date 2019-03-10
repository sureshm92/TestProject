/**
 * Created by user on 01.03.2019.
 */
({
    doInit : function (component, event, helper) {
        communityService.executeAction(component, 'getHelloMessage', null, function (returnValue) {
            component.set('v.message', returnValue);
        });
    }
})