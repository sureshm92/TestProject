/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        var trialId = communityService.getUrlParameter('id');
        var spinner = component.find('mainSpinner');
        spinner.show();
        window.addEventListener('resize', $A.getCallback(function(){
            helper.doUpdateStudyTitle(component);
        }));
        communityService.executeAction(component, 'getInitData', {
            trialId: trialId,
            delegateId: communityService.getDelegateId()
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
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
            setTimeout($A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
            }), 10);
        });
    },

    doUpdateRecords: function (component) {
        if(component.get('v.skipUpdate')) return;
        var spinner = component.find('recordsSpinner');
        spinner.show();
        var filter = component.get('v.siteFilter');
        var filterJSON = JSON.stringify(filter);
        var paginationJSON = JSON.stringify(component.get('v.paginationData'));
        communityService.executeAction(component, 'getRecords', {
            filterJSON: filterJSON,
            paginationJSON: paginationJSON,
            delegateId: communityService.getDelegateId()
        }, function (returnValue) {
            var result = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.pageList', result.siteList);
            component.set('v.mapMarkers',result.mapMarkers);
            var pagination = component.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPageCount = result.paginationData.currentPageCount;
            pagination.currentPage = result.paginationData.currentPage;
            component.set('v.paginationData', pagination);
            component.set('v.skipUpdate', false);
            spinner.hide();
        })
    },

})