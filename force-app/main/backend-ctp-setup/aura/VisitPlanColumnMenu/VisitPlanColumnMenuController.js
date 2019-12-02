/**
 * Created by Igor Malyuta on 25.09.2019.
 */

({
    doEditSelected: function (component, event, helper) {
        component.getEvent('onEdit').fire();
    },

    doCloneSelected: function (component, event, helper) {
        component.getEvent('onClone').fire();
    },

    doDeleteSelected: function (component, event, helper) {
        component.getEvent('onDelete').fire();
    }
});