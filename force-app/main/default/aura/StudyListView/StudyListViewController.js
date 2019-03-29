({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        let userMode = communityService.getUserMode();
        component.set('v.userMode', userMode);

        if (userMode === 'HCP') {
            communityService.executeAction(component, 'getHCPInitData', null, function (returnValue) {
                let initData = JSON.parse(returnValue);
                debugger;
                console.log('in getHCPInitData');
                console.log(initData);

                component.set("v.paginationData", initData.paginationData);
                component.set("v.filterData", initData.filterData);
                component.set("v.sortData", initData.sortData);
                component.set("v.currentPageList", initData.currentPageList);

                component.set("v.showSpinner", false);
                component.set('v.isInitialized', true);
            });
        } else {
            communityService.executeAction(component, 'getStudyTrialList', {
                userMode: userMode
            }, function (returnValue) {
                let initData = JSON.parse(returnValue);
                console.log('in getStudyTrialList');
                component.set('v.currentlyRecruitingTrials', initData.currentlyRecruitingTrials);
                component.set('v.trialsNoLongerRecruiting', initData.trialsNoLongerRecruiting);
                component.set("v.showSpinner", false);
                component.set('v.isInitialized', true);
                component.set('v.peStatusesPathList', initData.peStatusesPathList);
                component.set('v.peStatusStateMap', initData.peStatusStateMap);
                if (communityService.getUserMode() === 'Participant') {
                    component.set('v.currentlyRecruitingTrials', initData.peList);
                    component.set('v.trialsNoLongerRecruiting', initData.peListNoLongerRecr);
                }
            });
        }
    },

    doUpdateRecords: function (cmp, event, helper) {
        helper.searchForRecords(cmp);
    },

    showNoThanksDialog: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.currentTrialId', params.trialId);
        component.find('noTanksModal').show();
    },

    switchToSearchResume: function (cmp, event, helper) {
        cmp.set("v.isSearchResume", true);
        helper.searchForRecords(cmp);
    }
});