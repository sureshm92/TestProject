(
    {
        openOptInModal: function (component, event, helper) {
            component.set("v.showModal", true);
        },

        changeOptIn: function (component, event, helper) {
            helper.toggleOptIn(component,event);
        },
    }
);