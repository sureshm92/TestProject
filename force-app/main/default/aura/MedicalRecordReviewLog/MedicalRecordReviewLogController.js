({
    doInit: function(component, event, helper){
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            if (communityService.getUserMode() !== 'HCP') communityService.navigateToPage('');
            component.find('spinner').show();
            component.set('v.userMode', communityService.getUserMode());
            let trialId = component.get('v.trialId');
            let isFilterActive = (communityService.getUrlParameter('showPending') === 'true');

            communityService.executeAction(component, 'getParticipantDetail', {
                trialId: trialId ? trialId : null,
                userMode: component.get('v.userMode'),
                applyPendingFilter: isFilterActive,
                delegateId: communityService.getDelegateId()
            }, function (returnValue) {
                component.set('v.skipUpdate', true);
                let initData = JSON.parse(returnValue);
                component.set('v.currentPageList', initData.currentPageList);
                component.set('v.peFilter', initData.peFilter);
                component.set('v.peFilterData', initData.peFilterData);
                component.set('v.paginationData', initData.paginationData);
                component.set('v.summaryContainers', initData.summrayContainers);
                if (initData.filterInfo) {
                    let filterInfo = initData.filterInfo;
                    filterInfo.isActive = isFilterActive;
                    component.set('v.filterInfo', filterInfo);
                }
                component.set('v.skipUpdate', false);
                component.set('v.isInitialized', true);
                component.find('spinner').hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doUpdate: function(component, event, helper){
        if(component.get('v.skipUpdate')) return;
        let spinner = component.find('recordListSpinner');
        spinner.show();
        let filter = component.get('v.peFilter');
        let searchText = filter.searchText;
        let showMore = component.get('v.showMore');
        communityService.executeAction(component, 'getRecords', {
            filterJSON: JSON.stringify(filter),
            paginationJSON: (showMore?'':(JSON.stringify(component.get('v.paginationData')))),
            applyPendingFilter: component.get('v.filterInfo') ? component.get('v.filterInfo').isActive : false,
            delegateId: communityService.getDelegateId()
        }, function (returnValue) {

            if(component.get('v.peFilter').searchText !== searchText) return;
            component.set('v.skipUpdate', true);
            let result = JSON.parse(returnValue);
            component.set('v.currentPageList', result.currentPageList);
            component.set('v.paginationData.allRecordsCount', result.paginationData.allRecordsCount);
            if(!showMore){
                component.set('v.paginationData.currentPage', result.paginationData.currentPage);
                component.set('v.paginationData.currentPageCount', result.paginationData.currentPageCount);
            }
            else{
                component.set('v.paginationData.currentPageCount', result.paginationData.allRecordsCount);
            }
            component.set('v.skipUpdate', false);
            spinner.hide();
        });
    }
})