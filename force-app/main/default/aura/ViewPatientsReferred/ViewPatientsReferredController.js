/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, hepler) {
        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        var trialId = component.get('v.trialId');
        var siteId = component.get('v.siteId');
        var spinner = component.find('mainSpinner');
        spinner.show();

        communityService.executeAction(component, 'getInitData', {
            trialId: trialId,
            siteId: siteId,
            userMode: communityService.getUserMode(),
            delegateId: communityService.getDelegateId()
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.pageList', initData.currentPageList);
            component.set('v.peFilterData', initData.peFilterData);
            component.set('v.paginationData', initData.paginationData);
            component.set('v.peFilter', initData.peFilter);
            component.set('v.trialIds', initData.trialIds);
            component.set('v.peStatusesPathList', initData.peStatusesPathList);
            component.set('v.peStatusStateMap', initData.peStatusStateMap);
            component.set('v.statistics', initData.statistics);
            //component.set('v.changeStatusBtnList', initData.btnList);
            component.set('v.isInitialized', true);
            component.set('v.skipUpdate', false);
            spinner.hide();

            if (communityService.getUserMode() != 'Participant' && initData.currentPageList) {
                if (initData.hasEmancipatedParticipants) {
                    component.set('v.hasEmancipatedParticipants', initData.hasEmancipatedParticipants);
                    component.getEvent('onInit').fire();
                }
            }
        });
    },

    doStudyChanged: function (component, event, helper) {
        helper.doUpdateRecords(component, event, helper, 'study');
    },
    doSiteChanged: function (component, event, helper) {
        helper.doUpdateRecords(component, event, helper, 'site');
    },
    doFilterChanged: function (component, event, helper) {
        helper.doUpdateRecords(component, event, helper, 'filter');
    },
    doPaginationChanged: function (component, event, helper) {
        helper.doUpdateRecords(component, event, helper, 'pagination');
    },
    doActiveChanged: function (component, event, helper) {
        helper.doUpdateRecords(component, event, helper, 'active');
    },
    doSortChanged: function (component, event, helper) {
        helper.doUpdateRecords(component, event, helper, 'sort');
    },
    doEmancipatedChanged: function (component, event, helper) {
        helper.doUpdateRecords(component, event, helper, 'emancipation');
    },

    filterEmancipations: function(component, event, helper){
        console.log('aaaaa');
    	component.set('v.showEmancipatedOnly', true);
    },
})