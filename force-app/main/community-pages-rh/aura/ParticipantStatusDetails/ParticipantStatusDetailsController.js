/**
 * Created by Andrii Kryvolap.
 */
({
    doChangeStep : function (component, event, helper) {
        var steps = component.get('v.participantWorkflowWrapper.steps');
        component.set('v.participantWorkflowWrapper.currentStep',steps[event.currentTarget.dataset.stepInd]);
    }
})