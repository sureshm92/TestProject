({
    doShowHCPEnrollmentStatusDetail: function (component, event, helper) {
        debugger;
        var HCPEnrollment = event.getParam('arguments').HCPEnrollment;
        if(!HCPEnrollment) {
            communityService.showToast("error", "error", $A.get("$Label.c.TST_Something_went_wrong"));
            return;
        }
        component.set("v.HCPEnrollment", HCPEnrollment);

        component.set("v.title", $A.get("$Label.c.PG_IM_L_Provider_s_Status_Details"));
        component.set("v.showModal", true);
        component.set("v.showSpinner", true);

        var action = component.get('c.getHCPEnrollmentHistory');
        action.setParams({
            HSPEnrollmentId: HCPEnrollment.Id
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                debugger;
                var historyList = JSON.parse(response.getReturnValue());
                component.set("v.historyList", historyList);
                component.set("v.showSpinner", false);
            } else {
                communityService.showToast("error", "error", $A.get("$Label.c.TST_Something_went_wrong"));
                communityService.logErrorFromResponse(response);
            }
        });
        $A.enqueueAction(action);
    },
    doShowStudySiteStatusDetail: function (component, event, helper) {
        debugger;
        var studySite = event.getParam('arguments').studySite;
        if(!studySite) {
            communityService.showToast("error", "error", $A.get("$Label.c.TST_Something_went_wrong"));
            return;
        }
        component.set("v.studySite", studySite);
        component.set("v.title", $A.get("$Label.c.PG_IM_L_Study_Site_Status_Details"));
        component.set("v.showModal", true);
        component.set("v.showSpinner", true);

        var action = component.get('c.getStudySiteHistory');
        action.setParams({
            StudySiteId: studySite.Id
        });
        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {

                var historyList = JSON.parse(response.getReturnValue());
                component.set("v.historyList", historyList);
                component.set("v.showSpinner", false);
            } else {
                communityService.showToast("error", "error", $A.get("$Label.c.TST_Something_went_wrong"));
                communityService.logErrorFromResponse(response);
            }
        });
        $A.enqueueAction(action);
    }
})