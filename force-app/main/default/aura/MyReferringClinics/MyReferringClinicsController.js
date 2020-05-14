({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            if (communityService.getUserMode() !== "PI") communityService.navigateToPage('');
            let trialId = communityService.getUrlParameter('id');
            let ssId = communityService.getUrlParameter('ssId');
            communityService.executeAction(component, 'getInitData', {
                trialId: trialId ? trialId : null,
                ssId : ssId ? ssId : null
            }, function (returnValue) {
                let initData = JSON.parse(returnValue);
                component.set('v.skipUpdate', true);
                component.set('v.filterData', initData.referringClinicsFilter.filterData);
                component.set('v.filterValues', initData.referringClinicsFilter.filterValues);
                component.set('v.sortData', initData.referringClinicsFilter.sortData);
                component.set('v.paginationData', initData.paginationData);
                component.set('v.filteredReferringClinics', initData.filteredReferringClinics);
                component.set('v.isButtonDisabled', initData.isButtonDisabled);
                component.set('v.trialId',initData.trialId);
                component.set('v.ssId',initData.ssId);
                component.set('v.skipUpdate', false);
                component.set('v.showSpinner', false);
                component.set('v.isInitialized', true);
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
            component.set('v.showSpinner', false);
        }
    },

    doUpdateRecords: function (component){
        if(component.get('v.skipUpdate')) return;
        let spinner = component.find('recordListSpinner');
        spinner.show();
        let filterValues = component.get('v.filterValues');
        let sortDataJSON = JSON.stringify(component.get('v.sortData'));
        let paginationDataJSON = JSON.stringify(component.get('v.paginationData'));
        let trialId = component.get('v.trialId');
        let trialChanged = trialId !== filterValues.trialId;
        communityService.executeAction(component, 'searchReferringClinics', {
            filterValuesJSON: JSON.stringify(filterValues),
            sortDataJSON: sortDataJSON,
            paginationDataJSON: paginationDataJSON,
            trialChanged: trialChanged
        }, function (returnValue) {
            let initData = JSON.parse(returnValue);
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