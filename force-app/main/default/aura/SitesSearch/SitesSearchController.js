/**
 * Created by Kryvolap
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            let trialId = communityService.getUrlParameter('id');
            let spinner = component.find('mainSpinner');
            spinner.show();
            window.addEventListener('resize', $A.getCallback(function () {
                helper.doUpdateStudyTitle(component);
            }));
            communityService.executeAction(component, 'getInitData', {
                trialId: trialId,
                delegateId: communityService.getDelegateId()
            }, function (returnValue) {
                let initData = JSON.parse(returnValue);
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
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doUpdateRecords: function (component) {
        if(component.get('v.skipUpdate')) return;
        let spinner = component.find('recordsSpinner');
        spinner.show();
        let filter = component.get('v.siteFilter');
        let filterJSON = JSON.stringify(filter);
        let paginationJSON = JSON.stringify(component.get('v.paginationData'));
        communityService.executeAction(component, 'getRecords', {
            filterJSON: filterJSON,
            paginationJSON: paginationJSON,
            delegateId: communityService.getDelegateId()
        }, function (returnValue) {
            let result = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.pageList', result.siteList);
            component.set('v.mapMarkers',result.mapMarkers);
            let pagination = component.get('v.paginationData');
            pagination.allRecordsCount = result.paginationData.allRecordsCount;
            pagination.currentPageCount = result.paginationData.currentPageCount;
            pagination.currentPage = result.paginationData.currentPage;
            component.set('v.paginationData', pagination);
            component.set('v.skipUpdate', false);
            spinner.hide();
        })
    },

})