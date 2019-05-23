({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        let userMode = communityService.getUserMode();
        component.set('v.userMode', userMode);
        if (userMode === 'HCP') {
            window.addEventListener('resize', $A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
                // helper.doUpdateStudyDescription(component);
            }));
            communityService.executeAction(component, 'getHCPInitData', null, function (returnValue) {
                let initData = JSON.parse(returnValue);
                console.log('in getHCPInitData');
                console.log(initData);
                component.set("v.paginationData", initData.paginationData);
                component.set("v.filterData", initData.filterData);
                component.set("v.sortData", initData.sortData);
                component.set("v.accessUserLevel", initData.delegateAccessLevel);
                helper.prepareIcons(initData.currentPageList);
                component.set("v.currentPageList", initData.currentPageList);
                component.set("v.showSpinner", false);
                component.set('v.isInitialized', true);
                setTimeout($A.getCallback(function () {
                    helper.doUpdateStudyTitle(component);
                    // helper.doUpdateStudyDescription(component);
                }), 10);
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
        helper.searchForRecords(cmp, helper, false);
    },

    doUpdateRecordsWithFirstPage: function (cmp, event, helper) {
        helper.searchForRecords(cmp, helper, true);
    },

    showNoThanksDialog: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.currentTrialId', params.trialId);
        component.find('noTanksModal').show();
    },

    switchToSearchResume: function (cmp, event, helper) {
        cmp.set("v.isSearchResume", true);
        cmp.set("v.searchResumeChanged", true);
        helper.searchForRecords(cmp, helper);
    }
});