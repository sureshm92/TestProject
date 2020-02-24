/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, helper) {
        debugger;
        if (!communityService.isInitialized()) return;
        var peId = communityService.getUrlParameter('id');
        communityService.executeAction(component, 'getPrintInformation', {
            peId: peId,
            userMode: communityService.getUserMode(),
            delegateId: communityService.getDelegateId(),
        }, function (returnValue) {
            debugger;
            returnValue = JSON.parse(returnValue);
            component.set('v.isFinalUpdate', true);
            component.set('v.initialized', true);
            component.set('v.pe', returnValue.pe);
            component.set('v.participant', returnValue.pe.Participant__r);
            component.set('v.pathItems', returnValue.pathItems);
            //window.addEventListener("afterprint", function(event) { window.close(); });
            setTimeout(
                $A.getCallback(function () {
                   window.print();
                    window.close();
                }), 1000
            );
        });
    },
})