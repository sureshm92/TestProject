/**
 * Created by Olga Skrynnikova on 1/17/2020.
 */

({
    doInit : function(component, event, helper) {
        component.set('v.isOpen', true);
        var flow = component.find('flow');
        flow.startFlow('Study_Resources');
    },

    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
    },

    closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
        }
    }
})