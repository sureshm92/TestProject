({
    doInit: function (component, event, helper) {

        if (!communityService.isInitialized()) return;
        if(communityService.getUserMode() !== "HCP") communityService.navigateToPage("");

        component.set('v.userMode', communityService.getUserMode());

        var trialId = communityService.getUrlParameter('id');

        var action = component.get('c.getStudySiteDetail');
        action.setParams({
            trialId: trialId ? trialId : ''
        });

        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS" && response.getReturnValue()) {

                var initData = JSON.parse(response.getReturnValue());

                component.set("v.studySitesDetail", initData.studySitesDetail);
                component.set("v.filteredStudySitesDetail", initData.studySitesDetail);
                component.set("v.summaryContainers", initData.summrayContainers);
                component.set("v.filterInfo", initData.filterInfo);
                component.set("v.showEnrollments", !trialId);
                component.set("v.showSpinner", false);
            } else {
                communityService.logErrorFromResponse(response);
            }
        });
        $A.enqueueAction(action);
    },
    showPendingStudies: function (component, event, helper) {

        component.set("v.filteredStudySitesDetail", []);
        var isFilterActive = component.get("v.filterInfo").isActive;

        if(isFilterActive){
            var wrappers = component.get("v.studySitesDetail");
            var newWrappers = [];

            for(var i = 0; i < wrappers.length; i++){

                var newObj = {};
                newObj.studySite = wrappers[i].studySite;
                newObj.enrollments = [];

                for(var j = 0; j < wrappers[i].enrollments.length; j++){

                    var status = wrappers[i].enrollments[j].enrollment.Status__c;

                    if(status.indexOf("Pending") !== -1){

                        newObj.enrollments.push(wrappers[i].enrollments[j]);
                    }
                }

                if(newObj.enrollments.length){

                    newWrappers.push(newObj);
                }
            }

            if(newWrappers.length){
                component.set("v.filteredStudySitesDetail", newWrappers);
            }
        } else {
            component.set("v.filteredStudySitesDetail", component.get("v.studySitesDetail"));
        }
    }
})