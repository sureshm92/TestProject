/**
 * Created by Andrii Kryvolap.
 */
({
    doInit: function(component, event, helper){
            component.find('spinner').show();
            var pe = component.get('v.pe');
            communityService.executeAction(
                component,
                'prepareParticipantWorkflowHelper',
                {
                    peId: pe.Id,
                    userMode: communityService.getUserMode(),
                    delegateId: communityService.getDelegateId(),
                },
                function (returnValue) {
                    component.set('v.participantWorkflowWrapper',returnValue);
                    component.find('spinner').hide();
                }
            );
        
    },
    
    doChangeStep: function (component, event, helper) {
        component.set('v.updateInProgress', true);
        let currentStepInd = component.get('v.participantWorkflowWrapper.currentStepInd');
        let steps = component.get('v.participantWorkflowWrapper.steps');
        steps[currentStepInd].isCurrentStep = false;
        steps[event.currentTarget.dataset.stepInd].isCurrentStep = true;
        component.set('v.participantWorkflowWrapper.steps', steps);
        component.set(
            'v.participantWorkflowWrapper.currentStepInd',
            event.currentTarget.dataset.stepInd
        );
        component.set('v.updateInProgress', false);
    },
    doFieldChanged: function (component, event, helper) {
        var participantWorkflowWrapper = component.get('v.participantWorkflowWrapper');
        var updateInProgress = component.get('v.updateInProgress');
        if (!updateInProgress) {
            component.set('v.updateInProgress', true);
            var params = event.getParam('arguments');
            for (let i = 0; i < participantWorkflowWrapper.steps.length; i++) {
                helper.updateDependentFields(
                    component,
                    event,
                    helper,
                    participantWorkflowWrapper.steps[i],
                    params.fieldName,
                    params.value
                );
                helper.populateChangedValue(
                    component,
                    event,
                    helper,
                    participantWorkflowWrapper.steps[i],
                    params.fieldName,
                    params.value,
                    params.valid
                );
                if (params.fieldMap !== null) {
                    helper.populateFields(
                        component,
                        event,
                        helper,
                        participantWorkflowWrapper.steps[i],
                        params.fieldMap
                    );
                }
            }
            component.set('v.participantWorkflowWrapper', participantWorkflowWrapper);
            let stepCards = component.find('stepCard');
            if (stepCards !== undefined && !Array.isArray(stepCards)) {
                stepCards.updateFieldValidity();
            } else if (Array.isArray(stepCards)) {
                stepCards.forEach(function (step) {
                    step.updateFieldValidity();
                });
            }
            participantWorkflowWrapper = component.get('v.participantWorkflowWrapper');
            for (let j = 0; j < participantWorkflowWrapper.steps.length; j++) {
                if (
                    participantWorkflowWrapper.steps[j].isCurrentStep &&
                    participantWorkflowWrapper.steps[j].title ==
                    $A.get('$Label.c.PWS_Initial_Visit_Name')
                ) {
                    if (params.fieldName == 'Notes__c') {
                        participantWorkflowWrapper.steps[j].notes = params.value;
                    } else if (params.fieldName == 'Non_Enrollment_Reason__c') {
                        participantWorkflowWrapper.steps[j].reason = params.value;
                    }
                }
                helper.checkValidity(component, event, helper, participantWorkflowWrapper.steps[j]);
            }
            component.set('v.participantWorkflowWrapper', participantWorkflowWrapper);
            let parent = component.get('v.parent');
            parent.statusDetailValidityCheck(participantWorkflowWrapper);
            component.set('v.updateInProgress', false);
        }
    },
    
    doNotifyParent: function (component, event, helper) {
        var params = event.getParam('arguments');
        var notifyStatusDetails = component.getEvent('detectChildChanges');
        if (params && params.changesMap) {
            if (params.changesMap.isChanged) {
                notifyStatusDetails.setParams({
                    isChangedStatus: true,
                    source: 'STATUS'
                });
                notifyStatusDetails.fire();
                console.log('#Action_ParticipantInformation notified');
            }
        }
    }
});
