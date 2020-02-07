/**
 * Created by Andrii Kryvolap.
 */
({
    updateReasonList : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        component.set('v.reasonList', stepWrapper.reasonMap[stepWrapper.outcome]);
    },
    updateNotesRequired : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        component.set('v.notesRequired', stepWrapper.notesRequiredMap[stepWrapper.outcome+';'+stepWrapper.reason]);
    },
    doSaveChanges : function (component, event, helper) {
        var parent = component.get('v.parent');
        parent.doUpdatePatientStatus();
    },
})