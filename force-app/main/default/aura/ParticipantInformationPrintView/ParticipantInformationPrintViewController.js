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
            component.set('v.statusSteps', returnValue.steps);
            component.set('v.isFinalUpdate', true);
            component.set('v.initialized', true);
            component.set('v.pe', returnValue.enrollment);
            component.set('v.participant', returnValue.enrollment.Participant__r);
            component.set('v.peStatusesPathList', returnValue.peStatusesPathList);
            component.set('v.peStatusStateMap', returnValue.peStatusStateMap);
            helper.preparePathItems(component);
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