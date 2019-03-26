({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        component.set("v.showSpinner", true);
        let userMode = communityService.getUserMode();
        component.set('v.userMode', userMode);

        if (userMode === 'HCP') {
            communityService.executeAction(component, 'getHCPInitData', {
                userMode: userMode
            }, function (returnValue) {
                let initData = JSON.parse(returnValue);
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

    doUpdateRecords: function (component) {
        console.log('in doUpdateRecords');
        if (component.get('v.skipUpdate') === true || component.get('v.isInitialized') === false) {
            return;
        }

        console.log('in doUpdateRecords2');

        let spinner = component.find('recordsSpinner');
        spinner.show();
        let filter = component.get('v.filterData');
        let searchText = filter.searchText;
        let filterJSON = JSON.stringify(filter);
        let paginationJSON = JSON.stringify(component.get('v.paginationData'));
        let sortJSON = JSON.stringify(component.get('v.sortData'));

        communityService.executeAction(component, 'searchStudies', {
            filterData: filterJSON,
            sortData: sortJSON,
            paginationData: paginationJSON
        }, function (returnValue) {
            if (component.get('v.filterData').searchText !== searchText) return;
            console.log('in searchStudies callback');

            let result = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.currentPageList', result.records);

            let pagination = component.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPage = result.paginationData.currentPage;
            component.set('v.paginationData', pagination);

            component.set('v.skipUpdate', false);
            spinner.hide();
        })
    },

    showNoThanksDialog: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.currentTrialId', params.trialId);
        component.find('noTanksModal').show();
    }
});