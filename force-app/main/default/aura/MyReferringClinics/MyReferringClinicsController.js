({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        debugger;
        if (communityService.getUserMode() !== "PI") communityService.navigateToPage('');
        var trialId = communityService.getUrlParameter('id');
        var ssId = communityService.getUrlParameter('ssId');
        communityService.executeAction(component, 'getInitData', {
            trialId: trialId ? trialId : null,
            ssId : ssId ? ssId : null
        }, function (returnValue) {
            debugger;
            var initData = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set('v.filterData', initData.referringClinicsFilter.filterData);
            component.set('v.filterValues', initData.referringClinicsFilter.filterValues);
            component.set('v.sortData', initData.referringClinicsFilter.sortData);
            component.set('v.paginationData', initData.paginationData);
            component.set('v.filteredReferringClinics', initData.filteredReferringClinics);
            console.log('initData.filteredReferringClinics>>>', JSON.parse(JSON.stringify(initData.filteredReferringClinics)));
            component.set('v.trialId',initData.trialId);
            component.set('v.ssId',initData.ssId);
            component.set('v.skipUpdate', false);
            component.set('v.showSpinner', false);
            component.set('v.isInitialized', true);
        })
    },

    doUpdateRecords: function (component){
        debugger;
        if(component.get('v.skipUpdate')) return;
        var spinner = component.find('recordListSpinner');
        spinner.show();
        var filterValues = component.get('v.filterValues');
        var sortDataJSON = JSON.stringify(component.get('v.sortData'));
        var paginationDataJSON = JSON.stringify(component.get('v.paginationData'));
        var trialId = component.get('v.trialId');
        var trialChanged = trialId !== filterValues.trialId;
        communityService.executeAction(component, 'searchReferringClinics', {
            filterValuesJSON: JSON.stringify(filterValues),
            sortDataJSON: sortDataJSON,
            paginationDataJSON: paginationDataJSON,
            trialChanged: trialChanged
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            debugger;
            component.set('v.skipUpdate', true);
            if(trialChanged){
                component.set("v.filterData.studySitePickList", initData.referringClinicsFilter.filterData.studySitePickList);
            }
            component.set("v.filterValues.statusFilter", initData.referringClinicsFilter.filterValues.statusFilter);
            component.set("v.filterValues.trialId", initData.referringClinicsFilter.filterValues.trialId);
            component.set("v.filterValues.ssId", initData.referringClinicsFilter.filterValues.ssId);
            component.set('v.paginationData.allRecordsCount', initData.paginationData.allRecordsCount);
            component.set('v.paginationData.currentPage', initData.paginationData.currentPage);
            component.set('v.paginationData.currentPageCount', initData.paginationData.currentPageCount);
            component.set("v.filteredReferringClinics", initData.filteredReferringClinics);
            component.set('v.trialId',initData.trialId);
            component.set('v.ssId',initData.ssId);
            component.set('v.skipUpdate', false);
            spinner.hide();
        })
    },

    doShowInviteRP: function (component, event, helper) {
        component.find('inviteRPAction').execute();//component.find('invite-rp').show();
    }
})