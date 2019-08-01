/**
 * Created by Kryvolap on 04.09.2018.
 */
({
    doSaveSelectedStatus: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var step = component.get('v.step');
        rootComponent.find('mainSpinner').show();
        if(step.name = "Enrolled/Randomized" && step.selectedStatus == "Enrollment Success" && !component.get('v.entrollmentSuccess')){
            component.set('v.entrollmentSuccess',true);
            component.set('v.isShowPopup',true);
        } else {
            component.set('v.entrollmentSuccess',false);
            var statusReason = step.selectedStatus.split(';');
            var status, reason;
            status = statusReason[0];
            if (statusReason.length > 1) {
                reason = statusReason[1];
            }

            var notes = step.notes;
            var changePEStatusByPIAction = rootComponent.find('changePEStatusByPIAction');
            if (status === 'Enrollment Success' && pe.Informed_Consent__c !== true) {
                rootComponent.find('actionApprove').execute(function () {
                    changePEStatusByPIAction.execute(pe, status, reason, notes, rootComponent);
                }, function () {
                    rootComponent.find('mainSpinner').hide();
                    communityService.showWarningToast(null, $A.get('$Label.c.Toast_ICF'));
                });
            } else {
                changePEStatusByPIAction.execute(pe, status, reason, notes, rootComponent);
            }
        }
    },

    onStatusChange: function (component, event, helper) {
        var statusReason = component.get('v.step').selectedStatus;
        if (statusReason) {
            statusReason = statusReason.split(';');
            if (statusReason.length > 1 && statusReason[1] === "Other") {
                component.set('v.notesRequired', true);
            } else {
                component.set('v.notesRequired', false);
            }
        }
    }
})