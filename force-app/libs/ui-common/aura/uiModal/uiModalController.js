({
    doShow: function (component, event, helper) {
        component.set('v.isShow', true);
    },

    doHide: function (component, event, helper) {
        component.set('v.isShow', false);
    },

    doCancel: function (component, event, helper) {
        let cancelCallback = component.get('v.cancelCallback');
        if (cancelCallback) cancelCallback();
        component.hide();
    }
});