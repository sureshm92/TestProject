/**
 * Created by Leonid Bartenev
 */
({
    updatePE: function (component) {
        var helper = this;
        component.find('reasonSpinner').show();
        component.set('v.inProgress', true);
        var peId = component.get('v.peId');
        var status = component.get('v.status');
        var reason = component.get('v.reason');
        var notes = component.get('v.notes');

        communityService.executeAction(component, 'updatePE', {
            peId: peId,
            status: status,
            reason: reason,
            notes: notes
        }, null, null, function () {
            component.get('v.refreshSource').refresh();
            helper.hideDialogs(component);
        });
    },

    hideDialogs: function (component) {
        component.find('selectReferralDeclineReasonDialog').hide();
    }
})