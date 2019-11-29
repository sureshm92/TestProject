/**
 * Created by Leonid Bartenev
 */
({
    doInit: function (component) {
        communityService.executeAction(component, 'getReferralDeclineReasons', null, function (returnValue) {
            component.set('v.referralDeclineReasons', JSON.parse(returnValue));
            component.set('v.isInitialized', true);
        })
    },

    doExecute: function(component, event, helper){
        var params = event.getParam('arguments');
        var pe = params.pe;
        var status = params.status;
        var reason = params.reason;
        var notes = params.notes;
        var callback = params.callback;
        var cancelCallback = params.cancelCallback;
        component.set('v.pe', pe);
        component.set('v.peId', pe.Id);
        component.set('v.status', status);
        component.set('v.reason', reason);
        component.set('v.notes', notes);
        if(callback) component.set('v.callback', $A.getCallback(callback));
        if(cancelCallback) component.set('v.cancelCallback', $A.getCallback(cancelCallback));
        if(status === 'Referral Declined' && reason === null){
            var selectReferralDeclineReasonDialog = component.find('selectReferralDeclineReasonDialog');
            selectReferralDeclineReasonDialog.set('v.closeCallback', $A.getCallback(cancelCallback));
            selectReferralDeclineReasonDialog.show();
        }else if(status === 'Enrollment Success') {
            if (pe.Informed_Consent__c !== true) {
                component.find('actionApprove').execute(function () {
                    helper.updatePE(component);
                }, function () {
                    communityService.showWarningToast(null, $A.get('$Label.c.Toast_ICF'));
                    helper.cancel(component);
                });
            }else{
                helper.updatePE(component);
            }
        }else{
            helper.updatePE(component);
        }

    },

    doUpdatePE: function (component, event, helper) {
        helper.updatePE(component);
    },

    doCancel: function (component, event, helper) {
        helper.cancel(component);
    }

})