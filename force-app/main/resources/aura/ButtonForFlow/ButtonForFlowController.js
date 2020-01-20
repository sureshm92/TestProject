/**
 * Created by Olga Skrynnikova on 1/17/2020.
 */

({
    doInit : function(component, event, helper) {
        component.set('v.isOpen', true);
        var flow = component.find('flow');
        let recordId = component.get('v.recordId');
        flow.startFlow('Study_Resources', recordId);
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