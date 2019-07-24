(
    {
        openOptInModal: function (component, event, helper) {
            component.set("v.showModal", true);
        },

        handleOkClick: function (component, event, helper) {
            helper.toggleOptIn(component,event);
        },

        handleCancelClick: function(component, event, helper) {
            component.set('v.showModal', false);
        },
    }
);