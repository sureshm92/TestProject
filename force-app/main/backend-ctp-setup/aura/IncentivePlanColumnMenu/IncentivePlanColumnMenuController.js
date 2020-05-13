/**
 * Created by Alexey Moseev on 12.05.2020.
 */

({
    doEditSelected: function (component, event, helper) {
        component.getEvent('onEdit').fire();
    },

    doCloneSelected: function (component, event, helper) {
        component.getEvent('onClone').fire();
    }
});