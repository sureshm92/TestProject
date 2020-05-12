/**
 * Created by Igor Malyuta on 23.03.2019.
 */
({
    doInit: function (component, event, helper) {
        if (!communityService.isInitialized()) return;

        if(!communityService.isDummy()) {
            component.find('mainSpinner').show();
            component.set('v.userMode', communityService.getUserMode());
            communityService.executeAction(component, 'getDelegateByContactId', {
                id: communityService.getUrlParameter('id')
            }, function (returnValue) {
                component.set('v.delegate', JSON.parse(returnValue));
                if (!component.get('v.isInitialized')) communityService.setStickyBarPosition();
                component.set('v.isInitialized', true);
                component.find('mainSpinner').hide();
            });
        } else {
            component.find('builderStub').setPageName(component.getName());
        }
    },

    doSaveChanges: function (component, event, helper) {
        let delegate = component.get('v.delegate');

        component.find('mainSpinner').show();
        communityService.executeAction(component, 'editPatientDelegateDetail', {
            delegate: JSON.stringify(delegate)
        }, function () {
            communityService.showSuccessToast('Success', $A.get('$Label.c.Toast_Changes_Successfully'));
        });
        component.find('mainSpinner').hide();
    },

    doCheckEmail: function (component, event, helper) {
        let delegate = component.get('v.delegate');
        component.set('v.isCorrectEmail', communityService.isValidEmail(delegate.Email));
    }
});
