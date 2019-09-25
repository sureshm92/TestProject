({
    doInit: function (component, event, helper) {
        switch (component.get('v.size')) {
            case 'small':
                component.set('v.cssSize', 'slds-modal_small');
                break;
            case 'medium':
                component.set('v.cssSize', 'slds-modal_medium');
                break;
            case 'large':
                component.set('v.cssSize', 'slds-modal_large');
        }
    },

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