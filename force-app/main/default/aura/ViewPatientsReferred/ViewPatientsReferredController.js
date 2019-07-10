/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        console.log('ss ID = ',component.get('v.ssId'));
        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        var trialId = component.get('v.trialId');
        var siteId = component.get('v.siteId');
        var spinner = component.find('mainSpinner');
        spinner.show();
        var paramFilter = communityService.getUrlParameter("filter");

        communityService.executeAction(component, 'getInitData', {
            trialId: trialId,
            siteId: siteId,
            mode: communityService.getUserMode(),
            btnFilter: paramFilter,
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.piBtnFilter', paramFilter);
            component.set('v.skipUpdate', true);
            console.log('INIT DATA>>>>>>', initData);
            component.set('v.pageList', initData.currentPageList);
            component.set('v.peFilterData', initData.peFilterData);
            component.set('v.paginationData', initData.paginationData);
            component.set('v.peFilter', initData.peFilter);
            component.set('v.trialIds', initData.trialIds);
            component.set('v.peStatusesPathList', initData.peStatusesPathList);
            component.set('v.peStatusStateMap', initData.peStatusStateMap);
            component.set('v.statistics', initData.statistics);
            component.set('v.changeStatusBtnList', initData.btnList);
            component.set('v.isInitialized', true);
            component.set('v.skipUpdate', false);
            spinner.hide();
        });
    },

    doUpdateRecords: function (component) {
        if(component.get('v.skipUpdate')) return;
        var spinner = component.find('recordsSpinner');
        spinner.show();
        var filter = component.get('v.peFilter');
        var searchText = filter.searchText;
        var filterJSON = JSON.stringify(filter);
        debugger;
        var paginationJSON = JSON.stringify(component.get('v.paginationData'));
        var piBtnFilter = component.get('v.piBtnFilter');
        var action = component.get('c.getRecords');
        var trialId = component.get('v.trialId');

        communityService.executeAction(component, 'getRecords', {
            filterJSON: filterJSON,
            paginationJSON: paginationJSON,
            piBtnFilter: piBtnFilter,
            userMode: communityService.getUserMode(),
            studyChanged: trialId !== filter.study
        }, function (returnValue) {
            if(component.get('v.peFilter').searchText !== searchText) return;
            var result = JSON.parse(returnValue);
            debugger;
            component.set('v.skipUpdate', true);
            component.set('v.pageList', result.peList);
            if(trialId != filter.study){
                component.set('v.peFilterData.studySites', result.peFilterData.studySites);
                component.set('v.peFilter', result.peFilter);
                component.set('v.trialId', filter.study)
            }
            component.set('v.paginationData.allRecordsCount', result.paginationData.allRecordsCount);
            component.set('v.paginationData.currentPage', result.paginationData.currentPage);
            component.set('v.paginationData.currentPageCount', result.paginationData.currentPageCount);

            component.set('v.skipUpdate', false);
            spinner.hide();
        })
    },

    doUpdateStatistics: function (component) {
        communityService.executeAction(component, 'getStatistics', {
            mode: communityService.getUserMode()
        }, function (returnValue) {
            var statistics = JSON.parse(returnValue);
            component.set('v.statistics', statistics);
        });
    },

    doPIBtnFilterChanged: function (component) {
        var btnFilter = component.get('v.piBtnFilter');
        var filterMap = component.get('v.peFilterData').peBtnFilterItemsMap;
        var filter = component.get('v.peFilter');
        if(btnFilter){
            filter.peBtnFilter = filterMap[btnFilter];
        }else{
            filter.peBtnFilter = null;
        }
        component.set('v.peFilter', filter);
    }
})