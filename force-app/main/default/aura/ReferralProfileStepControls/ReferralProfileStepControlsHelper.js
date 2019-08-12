/**
 * Created by Leonid Bartenev
 */
({
    saveSelectedStatus: function (component) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        var step = component.get('v.step');
        rootComponent.find('mainSpinner').show();
        var statusReason = step.selectedStatus.split(';');
        var status, reason;
        status = statusReason[0];
        if (statusReason.length > 1) reason = statusReason[1];
        var notes = step.notes;
        rootComponent.find('changePEStatusByPIAction').execute(pe, status, reason, notes, function (pe, steps) {
            rootComponent.set('v.pe', pe);
            rootComponent.set('v.statusSteps', steps);
            rootComponent.find('mainSpinner').hide();
        }, function () {
            rootComponent.find('mainSpinner').hide();
        });
    }
})