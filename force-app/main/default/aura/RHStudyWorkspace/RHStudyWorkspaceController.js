({
    doInit: function (component, event, helper) {
        var spinner = component.get('v.parent').find('mainSpinner');
        spinner.show();
        var recId = communityService.getUrlParameter('id');
        var ssId = communityService.getUrlParameter('ssId');
        if(ssId) component.set('v.ssId', ssId);

        if(communityService.isInitialized()){
            component.set('v.userMode', communityService.getUserMode());
            component.set('v.state', communityService.getParticipantState());
            component.set('v.multiMode', communityService.getAllUserModes().length > 1);
            communityService.executeAction(component, 'getTrialDetail', {
                trialId: recId,
                userMode: communityService.getUserMode(),
                delegateId: communityService.getDelegateId(),
            }, function (returnValue) {
                var trialDetail = JSON.parse(returnValue);
                component.set('v.studyDetail', trialDetail);
                //get sticky bar position in browser window
                if(!component.get('v.isInitialized')) communityService.setStickyBarPosition();
                component.set('v.isInitialized', true);
                spinner.hide();
            });
        }
    }
})