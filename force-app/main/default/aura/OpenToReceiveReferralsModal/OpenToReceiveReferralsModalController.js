/**
 * Created by Leonid Bartenev
 */
({
    doShow: function (component, event, helper) {
        var parent = component.get('v.parent');
        var params = event.getParam('arguments');
        component.set('v.trialId', params.trial.Id);
        if(params.trial.Sponsor_Pays_for_Referral_Activity__c !== 'Yes'){
            parent.find('mainSpinner').show();
            helper.setStudyStatus(component);
        }else{
            component.find('reimbursmentModal').show();
        }
    },

    doHide: function (component) {
        component.find('reimbursmentModal').hide();
    },

    doSetStudyStatus: function (component, event, helper) {
        component.find('spinner').show();
        helper.setStudyStatus(component, event);
    }

})