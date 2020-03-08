/**
 * Created by Andrii Kryvolap.
 */
({
    doInit : function (component, event, helper) {
        var todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate',todayDate);
        var stepWrapper = component.get('v.stepWrapper');
        component.set('v.stepWrapper.currentOutcomeSuccess',stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1);
        component.set('v.reasonList', stepWrapper.reasonMap[stepWrapper.outcome]);
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    updateReasonList : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        component.set('v.stepWrapper.currentOutcomeSuccess',stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1);
        var reasonList = stepWrapper.reasonMap[stepWrapper.outcome];
        component.set('v.reasonList', reasonList);
        component.set('v.stepWrapper.reason',reasonList === undefined || reasonList.length==0?"":reasonList[0].value);
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    updateNotesRequired : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        component.set('v.notesRequired', stepWrapper.notesRequiredMap[stepWrapper.outcome+';'+stepWrapper.reason]);
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    checkNotesRequiredValidity : function (component, event, helper) {
        var stepWrapper = component.get('v.stepWrapper');
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    doUpdateFieldValidity : function (component, event, helper) {
        let inputFields = component.find('statusDetailField');
        if (inputFields !== undefined && !Array.isArray(inputFields)) {
            inputFields.checkValidity();
        } else if (inputFields !== undefined && Array.isArray(inputFields)) {
            inputFields.forEach(function (input) {
                input.checkValidity();
            })
        }

    }

})