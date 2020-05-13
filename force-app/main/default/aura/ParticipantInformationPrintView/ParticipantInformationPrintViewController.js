/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        var peId = communityService.getUrlParameter('id');
        communityService.executeAction(component, 'getPrintInfoWithSteps', {
            peId: peId,
            userMode: communityService.getUserMode(),
            delegateId: communityService.getDelegateId(),
        }, function (returnValue) {
            returnValue = JSON.parse(returnValue);
            var participantItem = JSON.parse(returnValue.participantItem); //return value of getPrintInformation();
            var initData = JSON.parse(returnValue.initData); //return value of getSteps()
            
            component.set('v.isFinalUpdate', true);
            component.set('v.initialized', true);
            component.set('v.pe', participantItem.pe);
            component.set('v.participant', participantItem.pe.Participant__r);
            component.set('v.pathItems', participantItem.pathItems);
            component.set('v.participantWorkflowWrapper', initData.steps);
            var steps = [];
            steps = component.get('v.participantWorkflowWrapper.steps');
            component.set('v.participantHistory', steps);
            
            setTimeout(
                $A.getCallback(function () {
                   window.print();
                    window.close();
                }), 1000
            );
        });
    },
})