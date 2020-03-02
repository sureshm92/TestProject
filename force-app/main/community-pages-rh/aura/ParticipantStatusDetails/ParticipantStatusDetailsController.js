/**
 * Created by Andrii Kryvolap.
 */
({
    doChangeStep : function (component, event, helper) {
        let currentStepInd = component.get('v.participantWorkflowWrapper.currentStepInd');
        let steps = component.get('v.participantWorkflowWrapper.steps');
        let currentStep =  component.get('v.participantWorkflowWrapper.currentStep');
        steps[currentStepInd] =currentStep;
        component.set('v.participantWorkflowWrapper.currentStep',steps[event.currentTarget.dataset.stepInd]);
        component.set('v.participantWorkflowWrapper.steps', steps);
        component.set('v.participantWorkflowWrapper.currentStepInd', event.currentTarget.dataset.stepInd);
    }
})