/**
 * Created by Kryvolap on 04.09.2018.
 */
({
    doSaveSelectedStatus: function (component, event, helper) {
        debugger;
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var step = component.get('v.step');
        if(step.selectedStatus === 'Enrollment Success'){
            rootComponent.find('updatePatientInfoAction').execute(pe, true, function (pe) {
                rootComponent.set('v.pe', pe);
                helper.saveSelectedStatus(component);
            }, function () {
                helper.cancel(component);
            });
        } else {
            helper.saveSelectedStatus(component);
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