/**
 * Created by Nargiz Mamedova on 1/9/2020.
 */

({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        component.find('addPaymentVendorDialog').show();
        component.find('addPaymentVendorDialog').set('v.cancelCallback', function () {
            helper.resetForm(component);
        })
    },

    doClose: function (component, event, helper) {
        component.find('addPaymentVendorDialog').cancel();
    },

    doSave: function (component, event, helper) {
        component.find('spinner').show();
        component.find('editForm').submit();
    },

    onSuccess: function (component, event, helper) {
        component.find('spinner').hide();
        component.find('addPaymentVendorDialog').hide();
        let callback = component.get('v.callback');
        if (callback) callback(event.getParams().response.id);
        helper.resetForm(component);
    },

    onError: function (component, event, helper) {
        component.find('spinner').hide();
    }
});