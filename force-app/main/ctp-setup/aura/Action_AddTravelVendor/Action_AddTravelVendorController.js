/**
 * Created by Leonid Bartenev
 */
({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        component.find('addTravelVendorDialog').show();
        component.find('addTravelVendorDialog').set('v.cancelCallback', function () {
            helper.resetForm(component);
        })
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
        if (callback) callback(event.getParams().response.id);
        helper.resetForm(component);
    },

    onError: function (component, event, helper) {
        component.find('spinner').hide();
    }
})