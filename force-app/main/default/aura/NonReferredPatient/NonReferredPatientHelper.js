({
	doUpdate: function (component, event, helper) {
        if (component.get('v.skipUpdate')) return;
        let spinner = component.find('recordListSpinner');
        spinner.show();
        let filter = component.get('v.peFilter');
        let searchText = filter.searchText;
        let showMore = component.get('v.showMore');
        communityService.executeAction(
            component,
            'getRecords',
            {
                filterJSON: JSON.stringify(filter),
                paginationJSON: showMore ? '' : JSON.stringify(component.get('v.paginationData')),
                applyPendingFilter: component.get('v.filterInfo')
                    ? component.get('v.filterInfo').isActive
                    : false,
                delegateId: communityService.getDelegateId(),
                userMode: component.get('v.userMode')
            },
            function (returnValue) {
                if (component.get('v.peFilter').searchText !== searchText) return;
                component.set('v.skipUpdate', true);
                let result = JSON.parse(returnValue);
                component.set('v.currentPageList', result.currentPageList);
                component.set(
                    'v.paginationData.allRecordsCount',
                    result.paginationData.allRecordsCount
                );
                if (!showMore) {
                    component.set(
                        'v.paginationData.currentPage',
                        result.paginationData.currentPage
                    );
                    component.set(
                        'v.paginationData.currentPageCount',
                        result.paginationData.currentPageCount
                    );
                } else {
                    component.set(
                        'v.paginationData.currentPageCount',
                        result.paginationData.allRecordsCount
                    );
                }
                component.set('v.skipUpdate', false);
                spinner.hide();
            }
        );
    },
})