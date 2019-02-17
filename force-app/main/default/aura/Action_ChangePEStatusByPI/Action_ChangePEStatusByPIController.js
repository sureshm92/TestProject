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
        var pe = event.getParam('arguments').pe;
        var status = event.getParam('arguments').status;
        var reason = event.getParam('arguments').reason;
        var notes = event.getParam('arguments').notes;
        var refreshSource = event.getParam('arguments').refreshSource;

        component.set('v.peId', pe.Id);
        component.set('v.status', status);
        component.set('v.reason', reason);
        component.set('v.notes', notes);
        component.set('v.refreshSource', refreshSource);

        if(status === 'Referral Declined' && reason === null){
            component.find('selectReferralDeclineReasonDialog').show();
        }else{
            helper.updatePE(component);
        }
    },

    doUpdatePE: function (component, event, helper) {
        helper.updatePE(component);
    },

    doHideDialogs: function (component, event, hepler) {
        hepler.hideDialogs(component);
    },

    doHideSpinner: function (component) {
        if(!component.get('v.inProgress')) component.get('v.refreshSource').find('mainSpinner').hide();
    }

})