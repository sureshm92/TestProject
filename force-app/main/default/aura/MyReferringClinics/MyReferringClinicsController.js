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
            console.log('FILTER DATA>>',initData);
            component.set("v.filterData", initData.filterData);
            component.set("v.sortData", initData.sortData);
            component.set("v.paginationData", initData.paginationData);
            component.set("v.filteredReferringClinics", initData.filteredReferringClinics);
            component.set('v.trialId',initData.trialId);
            component.set('v.ssId',initData.ssId);
            component.set('v.skipUpdate', false);
            component.set("v.showSpinner", false);
            component.set("v.isInitialized", true);
        })
    },

    doUpdateRecords: function (component){
        if(component.get('v.skipUpdate')) return;
        var spinner = component.find('recordListSpinner');
        spinner.show();
        var trialId = component.get('v.filterData.trialId');
        var ssId = component.get('v.filterData.ssId');
        communityService.executeAction(component, 'getInitData', {
            trialId: trialId ? trialId : null,
            ssId: ssId ? ssId : null
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set('v.skipUpdate', true);
            component.set("v.filterData", initData.filterData);
            component.set("v.sortData", initData.sortData);
            component.set("v.paginationData", initData.paginationData);
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