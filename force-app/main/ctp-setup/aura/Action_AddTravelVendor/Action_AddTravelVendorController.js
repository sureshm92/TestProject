/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        component.find('addTravelVendorDialog').show();
    },

    doClose: function (component, event, helper) {
        component.find('addTravelVendorDialog').cancel();
    },

    doSave: function (component, event, hepler) {
        component.find('spinner').show();
        component.find('editForm').submit();
    },

    onSuccess: function (component, event, helper) {
        let callback = component.get('v.callback');
        component.find('spinner').hide();
        component.find('addTravelVendorDialog').hide();
        debugger;
        if (callback) callback(event.getParams().response.id);
        component.set('v.hideForm', true);
        setTimeout(
            $A.getCallback(function () {
                component.set('v.hideForm', false);
            }), 100
        );
    },

    onError: function (component, event, helper) {
        component.find('spinner').hide();
    }
})