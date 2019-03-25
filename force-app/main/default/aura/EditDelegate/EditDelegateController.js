/**
 * Created by Igor Malyuta on 23.03.2019.
 */
({
    doInit: function (component, event, helper) {
        var spinner = component.find('mainSpinner');
        spinner.show();
        component.set('v.showSpinner', true);

        if (!communityService.isInitialized()) return;
        component.set('v.userMode', communityService.getUserMode());
        communityService.executeAction(component, 'getPatientDelegateByContactId', {
            id : communityService.getUrlParameter('id')
        }, function (returnValue) {
            var patientDelegate = JSON.parse(returnValue);
            component.set('v.delegate', patientDelegate.Contact__r);
            component.set('v.currentUserContactId', patientDelegate.Participant__c);

            if (!component.get('v.isInitialized')) communityService.setStickyBarPosition();
            component.set('v.isInitialized', true);
            component.set('v.showSpinner', false);
        })
    },

    doSaveChanges: function (component, event, helper) {
        var delegate = component.get('v.delegate');

        communityService.executeAction(component, 'editPatientDelegateDetail', {
            delegate: JSON.stringify(delegate)
        }, function (returnValue) {
            communityService.showSuccessToast('Success', $A.get('$Label.c.Toast_Changes_Successfully'));
        });
    },

    doCheckEmail: function (component, event, helper) {
        var delegate = component.get('v.delegate');
        component.set('v.isCorrectEmail', communityService.isValidEmail(delegate.Email));
    }
});
