({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        var userMode = communityService.getUserMode();
        component.set('v.userMode', userMode);

        communityService.executeAction(component, 'getStudyTrialList', {
            userMode: userMode
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.currentlyRecruitingTrials', initData.currentlyRecruitingTrials);
            component.set('v.trialsNoLongerRecruiting', initData.trialsNoLongerRecruiting);
            component.set("v.showSpinner", false);
            component.set('v.isInitialized', true);
            component.set('v.peStatusesPathList', initData.peStatusesPathList);
            component.set('v.peStatusStateMap', initData.peStatusStateMap);
            if(communityService.getUserMode() === 'Participant'){
                component.set('v.currentlyRecruitingTrials', initData.peList);
                component.set('v.trialsNoLongerRecruiting', initData.peListNoLongerRecr);

            }
        });
    },

    showNoThanksDialog: function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set('v.currentTrialId', params.trialId);
        component.find('noTanksModal').show();
    }

})