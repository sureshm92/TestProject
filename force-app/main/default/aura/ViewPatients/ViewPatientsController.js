/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        var spinner = component.find('mainSpinner');
        spinner.show();
        component.set('v.userMode', communityService.getUserMode());
        var trialId = communityService.getUrlParameter('id');
        component.set('v.trialId', trialId);
        var siteId = communityService.getUrlParameter('siteId');
        component.set('v.siteId', siteId);
        // var paramFilter = communityService.getUrlParameter("filter");
        // communityService.executeAction(component, 'getInitData', {
        //     trialId: trialId,
        //     mode: communityService.getUserMode(),
        //     btnFilter: paramFilter,
        //     userMode: component.get('v.userMode')
        // }, function (returnValue) {
        //     var initData = JSON.parse(returnValue);
        //     component.set('v.piBtnFilter', paramFilter);
        //     component.set('v.skipUpdate', true);
        //     component.set('v.pageList', initData.currentPageList);
        //     component.set('v.peFilterData', initData.peFilterData);
        //     component.set('v.paginationData', initData.paginationData);
        //     component.set('v.peFilter', initData.peFilter);
        //     component.set('v.trialIds', initData.trialIds);
        //     component.set('v.peStatusesPathList', initData.peStatusesPathList);
        //     component.set('v.peStatusStateMap', initData.peStatusStateMap);
        //     component.set('v.statistics', initData.statistics);
        //     component.set('v.changeStatusBtnList', initData.btnList);
            component.set('v.isInitialized', true);
        //     component.set('v.skipUpdate', false);
            spinner.hide();
        // });
    },
})