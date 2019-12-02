({
    doInit: function (component, event, helper) {

        var action = component.get('c.getEnrollmentReasonOptions');
        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {
                var reasonOptions = JSON.parse(response.getReturnValue());

                if (reasonOptions) {
                    helper.reasonOptions = reasonOptions;
                } else {
                    communityService.showErrorToast("Error", response.getError()[0].message);
                }
            } else {
                communityService.showErrorToast("Failed", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    doChangeStatus: function (component, event, helper) {

        if (event.currentTarget.id !== "ok") {
            component.set("v.showModal", false);
            return;
        }

        var spinner = component.find('spinner');
        if (spinner) spinner.show();

        var isDateNeeded = component.get("v.showDatapicker");
        var date = component.get("v.date");
        if(isDateNeeded){
            if (!date) {
                communityService.showErrorToast("Error", "Date incorrect!");
                if (spinner) spinner.hide();
                return;
            }
        } else {
            date = null;
        }

        var isReasonNeeded = component.get("v.showChangeStatusReason");
        var reason = component.get("v.reason");
        if (isReasonNeeded && !reason) {
            communityService.showErrorToast("Error", "Reason incorrect!");
            if (spinner) spinner.hide();
            return;
        }

        var actionType = component.get("v.actionType");
        var HCPEnrollment = component.get("v.HCPEnrollment");
        if (!actionType || !HCPEnrollment) {
            communityService.showErrorToast("Error", "Incorrect data!");
            if (spinner) spinner.hide();
            return;
        }

        var action = component.get('c.changeHCPEnrollmentStatus');
        action.setParams({
            HCPEnrollmentId: HCPEnrollment.Id,
            userMode: communityService.getUserMode(),
            newStatus: actionType,
            value: date ? date : reason
        });
        action.setCallback(this, function (response) {

            if (response.getState() === "SUCCESS") {

                helper.showMessage(HCPEnrollment, actionType);
                var parent = component.get("v.parent");
                if (parent) parent.refresh();
                component.set("v.showModal", false);
            } else {
                communityService.showErrorToast("Failed", response.getError()[0].message);
            }
            var spinner = component.find('spinner');
            if (spinner) spinner.hide();
        });
        $A.enqueueAction(action);
    },
    showChangeStatusToApprove: function (component, event, helper) {

        var HCPEnrollment = event.getParam('arguments').HCPEnrollment;
        if(!helper.canChangeStatus(HCPEnrollment)) return;
        component.set("v.HCPEnrollment", HCPEnrollment);
        var drName = helper.getDoctorName(HCPEnrollment);
        helper.resetComponent(component);

        component.set("v.showChangeStatusReason", false);
        component.set("v.changeStatusText", ('Please confirm that you want to approve\n ' + drName));
        component.set("v.primaryBtnLabel", "Approve");
        component.set("v.actionType", "approve");
        component.set("v.showModal", true);
    },
    showChangeStatusToActivate: function (component, event, helper) {

        var HCPEnrollment = event.getParam('arguments').HCPEnrollment;
        if(!helper.canChangeStatus(HCPEnrollment)) return;
        component.set("v.HCPEnrollment", HCPEnrollment);
        var drName = helper.getDoctorName(HCPEnrollment);
        helper.resetComponent(component);

        component.set("v.showChangeStatusReason", false);
        component.set("v.changeStatusText", ('Please confirm that you want to activate\n ' + drName));
        component.set("v.primaryBtnLabel", "Yes, Activate");
        component.set("v.actionType", "activate");
        component.set("v.showModal", true);
    },
    showChangeStatusToOrientationAttendAndActivate: function (component, event, helper) {

        var HCPEnrollment = event.getParam('arguments').HCPEnrollment;
        if(!helper.canChangeStatus(HCPEnrollment)) return;
        component.set("v.HCPEnrollment", HCPEnrollment);
        var drName = helper.getDoctorName(HCPEnrollment);
        helper.resetComponent(component);

        component.set("v.showChangeStatusReason", false);
        component.set("v.showDatapicker", true);
        component.set("v.changeStatusText", ('Please confirm your Orientation Attended date & Activate\n ' + drName));
        component.set("v.primaryBtnLabel", "Yes, Activate");
        component.set("v.actionType", "orientation-attend-activate");
        component.set("v.showModal", true);
    },
    showChangeStatusToOnHold: function (component, event, helper) {

        var HCPEnrollment = event.getParam('arguments').HCPEnrollment;
        if(!helper.canChangeStatus(HCPEnrollment)) return;
        component.set("v.HCPEnrollment", HCPEnrollment);
        var drName = helper.getDoctorName(HCPEnrollment);
        helper.resetComponent(component);

        component.set("v.showChangeStatusReason", true);
        component.set("v.reasonOptions", helper.reasonOptions["On Hold"]);
        component.set("v.changeStatusText", ('Please provide a reason for putting\n ' + drName + ' on hold'));
        component.set("v.actionType", "on-hold");
        component.set("v.showModal", true);
    },
    showChangeStatusToDecline: function (component, event, helper) {

        var HCPEnrollment = event.getParam('arguments').HCPEnrollment;
        if(!helper.canChangeStatus(HCPEnrollment)) return;
        component.set("v.HCPEnrollment", HCPEnrollment);
        var drName = helper.getDoctorName(HCPEnrollment);
        helper.resetComponent(component);

        console.log("hcpEId= " + HCPEnrollment.Id);

        component.set("v.showChangeStatusReason", true);
        component.set("v.reasonOptions", helper.reasonOptions["Declining"]);
        component.set("v.changeStatusText", ('Please provide a reason for declining\n ' + drName));
        component.set("v.actionType", "decline");
        component.set("v.showModal", true);
    },
    showChangeStatusToDeactivate: function (component, event, helper) {

        var HCPEnrollment = event.getParam('arguments').HCPEnrollment;
        if(!helper.canChangeStatus(HCPEnrollment)) return;
        component.set("v.HCPEnrollment", HCPEnrollment);
        var drName = helper.getDoctorName(HCPEnrollment);
        helper.resetComponent(component);

        component.set("v.showChangeStatusReason", true);
        component.set("v.reasonOptions", helper.reasonOptions["Deactivation"]);
        component.set("v.changeStatusText", ('Please provide a reason for deactivating\n ' + drName));
        component.set("v.actionType", "deactivate");
        component.set("v.showModal", true);
    }
})