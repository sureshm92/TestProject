/**
 * Created by Leonid Bartenev
 */
({
    saveSelectedStatus: function (component) {
        var parent = component.get('v.parent');
        var rootComponent = component.get('v.rootComponent');
        var pe = component.get('v.pe');
        var step = component.get('v.step');
        parent.find('spinner').show();
        var statusReason = step.selectedStatus.split(';');
        var status, reason;
        status = statusReason[0];
        if (statusReason.length > 1) reason = statusReason[1];
        var notes = step.notes;
        rootComponent.find('changePEStatusByPIAction').execute(pe, status, reason, notes, function (pe, steps) {
            parent.set('v.pe', pe);
            parent.set('v.statusSteps', steps);
            parent.doCallback();
        }, function () {
            parent.find('spinner').hide();
        });
    }
})