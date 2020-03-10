/**
 * Created by Leonid Bartenev
 */
({
    doLoadHistory: function (component, event, helper) {
        var pathItems = component.get('v.pathItems');
        var peId = component.get('v.peId');
        if (!pathItems) return;
        communityService.executeAction(component, 'getParticipationStatusHistory', {
            peId: peId
        }, function (returnValue) {
            var pathItems = JSON.parse(returnValue);
            component.set('v.pathItems', pathItems);
        }, null, function () {
            component.find('spinner').hide();
        });
    }

})