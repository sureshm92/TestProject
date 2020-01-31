/**
 * Created by Olga Skrynnikova on 1/17/2020.
 */

({
    doInit : function(component, event, helper) {
        component.set('v.isOpen', true);
        var flow = component.find('flow');
        let recordId = component.get('v.recordId');
        var pageRef = component.get("v.pageReference");
        if(pageRef != null) {
            var state = pageRef.state;
            if(state != null) {
                var base64Context = state.inContextOfRef;
                if (base64Context) {
                    if (base64Context.startsWith("1\.")) {
                        base64Context = base64Context.substring(2);
                        var addressableContext = window.atob(base64Context);
                        var pageReferencePrevious = JSON.parse(addressableContext);
            			if(pageReferencePrevious != null && pageReferencePrevious.attributes != null){
                            if(pageReferencePrevious.attributes.objectApiName === 'Clinical_Trial_Profile__c') {
                    			recordId = pageReferencePrevious.attributes.recordId;
                            }else if(pageReferencePrevious.attributes.relationshipApiName === 'Resource__r') {
                                recordId = pageReferencePrevious.attributes.recordId;
                            } else if (pageReferencePrevious.attributes.objectApiName === 'Res_study__c'){
                                recordId = '';
                            }
                        }
                    }
                }
            }
        }
        let inputVars = [
                { name: "recordId", type: "String", value: recordId}     
        ];
        flow.startFlow('Study_Resources', inputVars);
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