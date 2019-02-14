/**
 * Created by Kryvolap on 04.09.2018.
 */
({
    doSaveSelectedStatus: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        var pe = component.get('v.pe');
        var step = component.get('v.step');
        var statusReason = step.selectedStatus.split(';');
        var status, reason;
        status = statusReason[0];
        if (statusReason.length > 1) {
            reason = statusReason[1];
        }
        var notes = step.notes;
        var changePEStatusByPIAction = rootComponent.find('changePEStatusByPIAction');
        changePEStatusByPIAction.execute(pe, status, reason, notes, rootComponent);
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