/**
 * Created by Andrii Kryvolap.
 */
({
    doChangeStep : function (component, event, helper) {
        component.set('v.participantWorkflowWrapper.currentStep',event.currentTarget.dataset.step);
    }
})