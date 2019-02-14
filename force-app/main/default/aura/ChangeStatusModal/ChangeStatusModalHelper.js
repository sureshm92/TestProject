({
    reasonOptions: {},
    showMessage: function (HCPEnrollment, actionType) {

        var drName = this.getDoctorName(HCPEnrollment);
        var message = $A.get("$Label.c.TST_You_have_successfully") + " ";

        switch (actionType) {
            case 'approve':
                message += $A.get("$Label.c.TST_approved") + " " + drName + ".";
                break;
            case 'activate':
                message += $A.get("$Label.c.TST_activated") + " " + drName + ".";
                break;
            case 'orientation-attend-activate':
                message += $A.get("$Label.c.TST_attended_orientation_and_activated") + " " + drName + ".";
                break;
            case 'on-hold':
                message += $A.get("$Label.c.TST_put_On_Hold") + " " + drName + ".";
                break;
            case 'decline':
                message += $A.get("$Label.c.TST_declined") + " " + drName + ".";
                break;
            case 'deactivate':
                message += $A.get("$Label.c.TST_deactivated") + " " + drName + ".";
                break;
            default:
                return;
        }

        communityService.showToast("success", "success", message);
    },
    getDoctorName: function (HCPEnrollment) {
        var drName = $A.get("$Label.c.PG_DBPI_Dr") + ' ', drFirstName = '', drLastName = '';
        if (HCPEnrollment.HCP_Contact__r && HCPEnrollment.HCP_Contact__r.FirstName) drFirstName = HCPEnrollment.HCP_Contact__r.FirstName;
        if (HCPEnrollment.HCP_Contact__r && HCPEnrollment.HCP_Contact__r.LastName) drLastName = HCPEnrollment.HCP_Contact__r.LastName;

        if (drFirstName) drName += drFirstName;
        if (drLastName) drName += ' ' + drLastName;

        return drName;
    },
    resetComponent: function (component) {
        component.set("v.showDatapicker", false);
        component.set("v.showChangeStatusReason", true);
        component.set("v.reason", '');
        component.set("v.reasonOptions", []);
        component.set("v.title", "Change Provider’s Status");
        component.set("v.changeStatusText", "Please confirm");
        component.set("v.primaryBtnLabel", "Save");
        component.set("v.secondaryBtnLabel", "Cancel");
    },
    canChangeStatus: function (enrollment) {
        if (enrollment.Status__c.indexOf("(Admin)") !== -1) {
            communityService.showErrorToast("Error", $A.get("$Label.c.TST_The_status_of_this_record_is_locked_by_site_administration_For_more_inform"));
            return false;
        }
        return true;
    }
})