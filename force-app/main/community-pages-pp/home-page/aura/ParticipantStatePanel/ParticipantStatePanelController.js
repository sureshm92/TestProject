/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        component.find('spinner').show();
        communityService.executeAction(component,
            'getInitData',
            null,
            function (returnValue) {
                var participantItem = JSON.parse(returnValue);
                component.set('v.participantItem', participantItem);
            }, null, function () {
                component.find('spinner').hide();
            });
    }
})