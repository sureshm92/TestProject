/**
 * Created by Andrii Kryvolap.
 */
({
    doAccept: function (component, event, helper) {
        var pe = component.get('v.pe');
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        var changePEStatusAction = rootComponent.find('changePEStatusByPIAction');
        changePEStatusAction.execute(pe, 'Referral Accepted', null, null, function () {
            rootComponent.refresh();
        });
    },
    doAcceptAll: function (component, event, helper) {
        var pe = component.get('v.pe');
        var rootComponent = component.get('v.parent');
        rootComponent.find('mainSpinner').show();
        var changePEStatusAction = rootComponent.find('changePEStatusByPIAction');
        changePEStatusAction.execute(pe, 'Referral Accepted', null, null, function () {
            rootComponent.refresh();
        });
    },
    doOpenPatientInfo: function (component, event, helper) {
        var rootComponent = component.get('v.parent');
        var pe = component.get('v.pe');
        debugger;
        rootComponent.find('updatePatientInfoAction').execute(pe.data, null, 'personalInfoAnchor', null, rootComponent, function (enrollment) {
            component.set('v.pe', enrollment);
            if(enrollment.Participant_Status__c == 'Enrollment Success'){
                rootComponent.refresh();
            }
        });
    }
})