/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component, event, helper) {
        communityService.executeAction(component, 'getEnrollmentReasonOptions', null, function (returnValue) {
            component.set('v.changeStatusReasons', JSON.parse(returnValue));
        });
    },

    doChangeStatus: function (component, event, helper) {
        var spinner = component.find('dialogSpinner');
        spinner.show();
        var refreshSource = component.get('v.refreshSource');
        var date = component.get('v.date');
        var reason = component.get('v.reason');
        var hcpe = component.get('v.hcpEnrollment');
        var actionId = component.get('v.actionId');
        communityService.executeAction(component, 'changeHCPEnrollmentStatus', {
            hcpeId: hcpe.Id,
            actionId: actionId,
            value: date ? date : reason
        }, function (returnValue) {
            communityService.showToast('', 'success', returnValue);
        }, null, function () {
            spinner.hide();
            component.find('changeHCPStatusByPIDialog').hide();
            refreshSource.refresh();
        });
    },

    doCancel: function(component){
        component.find('changeHCPStatusByPIDialog').hide();
        component.find('dialogSpinner').hide();
    },

    doHideSPinner: function(component){
        component.get('v.refreshSource').find('mainSpinner').hide();
    },

    doExecute: function (component, event, hepler) {
        //init params:
        var params = event.getParam('arguments');
        component.set('v.hcpEnrollment', params.hcpEnrollment);
        component.set('v.actionId', params.actionId);
        component.set('v.refreshSource', params.refreshSource);
        params.refreshSource.find('mainSpinner').show();

        //reset:
        component.set("v.showDatePicker", false);
        component.set("v.reason", null);
        component.set("v.date", null);
        component.set("v.dateInputErrorMsg", '');
        component.set("v.reasonOptions", []);
        component.set("v.title", $A.get("$Label.c.PG_ACPE_L_Change_Provider_s_Status"));
        component.set("v.primaryBtnLabel", $A.get("$Label.c.BTN_Save"));
        component.set("v.secondaryBtnLabel", $A.get("$Label.c.BTN_Cancel"));

        //process action:
        var changeStatusReasons = component.get('v.changeStatusReasons');
        var drName = params.hcpEnrollment.HCP_Contact__r.Name;
        switch (params.actionId){
            case 'hcpApprove':
                component.set("v.changeStatusText", ($A.get("$Label.c.PG_ACPE_L_Please_confirm_that_you_want_to_approve") + '\n ' + drName));
                component.set("v.primaryBtnLabel", $A.get("$Label.c.BTN_Approve"));
                break;
            case 'hcpActivate':
                component.set("v.changeStatusText", ($A.get("$Label.c.PG_ACPE_L_Please_confirm_that_you_want_to_activate") + '\n ' + drName));
                component.set("v.primaryBtnLabel", $A.get("$Label.c.BTN_Yes_Activate"));
                break;
            case 'hcpOrientationAttendedAndActivate':
                component.set("v.showDatePicker", true);
                component.set("v.changeStatusText", ($A.get("$Label.c.PG_ACPE_L_Please_confirm_your_Orientation_Attended_date_Activate") + '\n ' + drName));
                component.set("v.primaryBtnLabel", $A.get("$Label.c.BTN_Yes_Activate"));
                break;
            case 'hcpDecline':
                component.set("v.changeStatusText", ($A.get("$Label.c.PG_ACPE_L_Please_provide_a_reason_for_declining") +  '\n ' + drName));
                component.set("v.reasonOptions", changeStatusReasons.declineReasons);
                break;
            case 'hcpOnHold':
                component.set("v.changeStatusText", ($A.get("$Label.c.PG_ACPE_L_Please_provide_a_reason_for_putting") +  '\n ' + drName + ' ' + $A.get("$Label.c.PG_ACPE_L_on_hold")));
                component.set("v.reasonOptions", changeStatusReasons.onHoldReasons);
                break;
            case 'hcpDeactivate':
                component.set("v.changeStatusText", ($A.get("$Label.c.PG_ACPE_L_Please_provide_a_reason_for_deactivating") + '\n ' + drName));
                component.set("v.reasonOptions", changeStatusReasons.deactivateReasons);
                break
        }
        component.find('changeHCPStatusByPIDialog').show();
    }

})