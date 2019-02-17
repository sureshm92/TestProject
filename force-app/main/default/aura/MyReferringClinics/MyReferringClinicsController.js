({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;
        if (communityService.getUserMode() !== "PI") communityService.navigateToPage('');
        component.set('v.userMode', communityService.getUserMode());
        var isFilterActive = (communityService.getUrlParameter('showPending') === 'true');
        var trialId = communityService.getUrlParameter('id');

        communityService.executeAction(component, 'getClinicDetail', {
            trialId: trialId ? trialId : '',
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            var initData = JSON.parse(returnValue);
            component.set("v.referringClinics", initData.referringClinics);
            component.set("v.filteredReferringClinics", initData.referringClinics);
            component.set("v.summaryContainers", initData.summrayContainers);
            component.set("v.filterInfo", initData.filterInfo);
            component.set("v.showFilterByStudy", !trialId);
            if (isFilterActive) {
                var filterInfo = component.get("v.filterInfo");
                filterInfo.isActive = true;
                component.set("v.filterInfo", filterInfo);
                helper.sortByPending(component, event, helper);
            }
            component.set("v.showSpinner", false);
        })
    },

    showPendingPhysicans: function (component, event, helper) {
        helper.sortByPending(component, event, helper);
    }
})