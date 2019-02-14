({
    showPopUpInfo: function (component, event, helper) {
        var enrollment = component.get("v.enrollmentData").enrollment;
        var modal = component.find('infoModal');
        if(modal) modal.showHCPEnrollmentStatusDetail(enrollment);
    },

    doAction: function (component, event, helper) {
        var actionId = event.currentTarget.id;
        var enrollment = component.get("v.enrollmentData").enrollment;
        if (!actionId || !enrollment) {
            communityService.showErrorToast("Error", $A.get("$Label.c.TST_Something_went_wrong"));
            return;
        }
        component.get('v.parent').find('changeHCPStatusByPIAction').execute(enrollment, actionId, component);
    },

    handelChangeStatus: function (component, event, helper) {
        var spinner = component.find('mainSpinner');
        var enrollment = component.get("v.enrollmentData").enrollment;
        if (spinner) spinner.show();
        communityService.executeAction(component, 'getEnrollmentData', {
            hcpEnrollmentId: enrollment.Id,
            userMode: component.get('v.userMode')
        }, function (returnValue) {
            var getEnrollmentData = JSON.parse(returnValue);
            component.set("v.enrollmentData", getEnrollmentData);
            if (spinner) spinner.hide();
        });
    }
})