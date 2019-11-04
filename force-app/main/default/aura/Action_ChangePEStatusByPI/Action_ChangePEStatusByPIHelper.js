/**
 * Created by Leonid Bartenev
 */
({
    updatePE: function (component) {
        var helper = this;
        component.find('spinner').show();
        component.set('v.inProgress', true);
        var peId = component.get('v.peId');
        var pe = component.get('v.pe');
        pe.sobjectType = 'Participant_Enrollment__c';
        var status = component.get('v.status');
        var reason = component.get('v.reason');
        var notes = component.get('v.notes');
        communityService.executeAction(component, 'updatePE', {
            pe: JSON.stringify(pe),
            status: status,
            reason: reason,
            notes: notes
        }, function(returnValue){
            var res = JSON.parse(returnValue);
            if(component.get('v.callback')) component.get('v.callback')(res.enrollment, res.steps);
        }, null, function () {
            helper.cancel(component);
        });
    },

    cancel: function (component) {
        component.find('selectReferralDeclineReasonDialog').cancel();
        if(component.get('v.cancelCallback')) component.get('v.cancelCallback')();
        component.find('spinner').hide();
    }
})