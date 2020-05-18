/**
 * Created by Andrii Kryvolap.
 */
({
    doChangeStep : function (component, event, helper) {
        component.set('v.updateInProgress', true);
        let currentStepInd = component.get('v.participantWorkflowWrapper.currentStepInd');
        let steps = component.get('v.participantWorkflowWrapper.steps');
        steps[currentStepInd].isCurrentStep = false;
        steps[event.currentTarget.dataset.stepInd].isCurrentStep = true;
        component.set('v.participantWorkflowWrapper.steps', steps);
        component.set('v.participantWorkflowWrapper.currentStepInd', event.currentTarget.dataset.stepInd);
        component.set('v.updateInProgress', false);
        
    },
    doFieldChanged : function (component, event, helper) {
        var participantWorkflowWrapper = component.get('v.participantWorkflowWrapper');
        var updateInProgress = component.get('v.updateInProgress');
        if(!updateInProgress) {
            component.set('v.updateInProgress', true);
            var params = event.getParam('arguments');
            for(let i = 0; i < participantWorkflowWrapper.steps.length; i++)
            {
                helper.updateDependentFields(component, event, helper, participantWorkflowWrapper.steps[i], params.fieldName, params.value);
                helper.populateChangedValue(component, event, helper, participantWorkflowWrapper.steps[i], params.fieldName, params.value, params.valid);
                if (params.fieldMap !== null) {
                    helper.populateFields(component, event, helper,participantWorkflowWrapper.steps[i],  params.fieldMap);
                }
            }
            component.set('v.participantWorkflowWrapper', participantWorkflowWrapper);
            let stepCards = component.find('stepCard');
            if (stepCards !== undefined && !Array.isArray(stepCards)) {
                stepCards.updateFieldValidity();
            } else if (Array.isArray(stepCards)) {
                stepCards.forEach(function (step) {
                    step.updateFieldValidity();
                })
            }
            participantWorkflowWrapper = component.get('v.participantWorkflowWrapper');
            for(let j = 0; j < participantWorkflowWrapper.steps.length; j++)
            {
                helper.checkValidity(component, event, helper, participantWorkflowWrapper.steps[j]);
            }
            component.set('v.participantWorkflowWrapper', participantWorkflowWrapper);
            let parent = component.get('v.parent');
            parent.statusDetailValidityCheck();
            component.set('v.updateInProgress', false);
        }
    },
    
    doNotifyParent: function(component, event, helper){
        var params = event.getParam('arguments');
        var notifyStatusDetails = component.getEvent("detectChildChanges");
        if(params && params.changesMap){
            if(params.changesMap.isChanged){
                notifyStatusDetails.setParams({
                    "isChangedStatus" : true,
                    "source" : "STATUS"
                });
                notifyStatusDetails.fire();
                console.log('#Action_ParticipantInformation notified');
            }
            
        }
    }
})