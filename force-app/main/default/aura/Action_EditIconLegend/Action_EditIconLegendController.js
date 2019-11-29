/**
 * Created by Igor Malyuta on 24.09.2019.
 */

({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.iconDetails', params.iconDetails);
        if(params.callback) component.set('v.callback', params.callback);
        component.find('modal').show();
    },

    cancelClick: function (component, event, helper) {
        component.find('modal').hide();
    },

    saveClick: function (component, event, helper) {
        let callback = component.get('v.callback');
        if(callback) callback(component.get('v.iconDetails'));
        component.find('modal').hide();
    }
});