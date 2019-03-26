/**
 * Created by Leonid Bartenev
 */
({
    doLoadHistory: function (component, event, helper) {
        var pathItems = component.get('v.pathItems');
        var pseId = component.get('v.pseId');
        if (!pathItems) return;
        communityService.executeAction(component, 'getPSEStatusHistory', {
            pseId: pseId
        }, function (returnValue) {
            var pathItems = JSON.parse(returnValue);
            component.set('v.pathItems', pathItems);
        }, null, function () {
            component.find('spinner').hide();
        });
    }

})