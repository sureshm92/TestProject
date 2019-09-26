/**
 * Created by Igor Malyuta on 24.09.2019.
 */

({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        let visit = params.visit;
        if (!visit) {
            visit = {
                sobjectType: 'Visit__c',
                Icons__c: ''
            }
        }

        component.set('v.visit', visit);
        component.set('v.callback', params.callback);
        component.set('v.cancelCallback', params.cancelCallback);
        component.set('v.isVisible', true);

        let modal = component.find('modal');
        modal.set('v.cancelCallback', params.cancelCallback);
        modal.show();
    },

    saveVisit: function (component, event, helper) {
        let callback = component.get('v.callback');
        if (callback) callback(component.get('v.visit'));
        component.find('modal').hide();
        component.set('v.isVisible', false);
    },

    cancelClick: function (component, event, helper) {
        component.find('modal').cancel();
        component.set('v.isVisible', false);
    }
});