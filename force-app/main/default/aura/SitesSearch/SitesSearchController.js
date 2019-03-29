/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        var trialId = communityService.getUrlParameter('id');
        var spinner = component.find('mainSpinner');
        spinner.show();

        communityService.executeAction(component, 'getInitData', {
            trialId: trialId
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            debugger;
            component.set('v.skipUpdate', true);
            component.set('v.trial', initData.trial);
            component.set('v.pageList', initData.currentPageList);
            component.set('v.siteFilterData', initData.siteFilterData);
            component.set('v.paginationData', initData.paginationData);
            component.set('v.siteFilter', initData.siteFilter);
            component.set('v.isInitialized', true);
            component.set('v.mapMarkers', initData.mapMarkers);

            component.set('v.skipUpdate', false);
            spinner.hide();
        });
    },

    doUpdateRecords: function (component) {
        debugger;
        if(component.get('v.skipUpdate')) return;
        var spinner = component.find('recordsSpinner');
        spinner.show();
        var filter = component.get('v.siteFilter');
        var filterJSON = JSON.stringify(filter);
        var paginationJSON = JSON.stringify(component.get('v.paginationData'));
        communityService.executeAction(component, 'getRecords', {
            filterJSON: filterJSON,
            paginationJSON: paginationJSON,
        }, function (returnValue) {
            var result = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.pageList', result.siteList);
            component.set('v.mapMarkers',result.mapMarkers);
            var pagination = component.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPage = result.paginationData.currentPage;
            component.set('v.paginationData', pagination);
            component.set('v.skipUpdate', false);
            spinner.hide();
        })
    },
})