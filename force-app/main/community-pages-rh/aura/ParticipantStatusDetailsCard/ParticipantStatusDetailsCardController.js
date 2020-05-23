/**
 * Created by Andrii Kryvolap.
 */
({
    doInit : function (component, event, helper) {
        let todayDate = $A.localizationService.formatDate(new Date(), 'YYYY-MM-DD');
        component.set('v.todayDate',todayDate);
        let stepWrapper = component.get('v.stepWrapper');
        
        component.set('v.stepWrapper.currentOutcomeSuccess',stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1);
        component.set('v.reasonList', stepWrapper.reasonMap[stepWrapper.outcome]);
        component.set('v.previousSelectedOutcome', stepWrapper.outcome);
        component.set('v.disableReason', true);
        
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    updateReasonList : function (component, event, helper) {
        let stepWrapper = component.get('v.stepWrapper');
        let previousSelectedOutcome = component.get('v.previousSelectedOutcome');
        let selectedOutcome = component.find('outcomeList').get('v.value');
        let outcomePlaceholder = component.get('v.stepWrapper.outcomePlaceholder');
        let parent = component.get('v.parent');

        if (!$A.util.isUndefinedOrNull(selectedOutcome) &&  selectedOutcome !== outcomePlaceholder){
            component.set('v.stepWrapper.outcome', selectedOutcome);
            component.set('v.stepWrapper.currentOutcomeSuccess',stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1);
            let reasonList = stepWrapper.reasonMap[stepWrapper.outcome];
            component.set('v.reasonList', reasonList);
            component.set('v.disableReason', false);
            component.set('v.stepWrapper.reason',reasonList === undefined || reasonList.length==0?"":reasonList[0].value);
            component.set('v.previousSelectedOutcome', stepWrapper.outcome);
            var changesMap = {title : 'outcome',
                              type : 'picklist',
                              isChanged : true};
            parent.notifyParent(changesMap);
            //console.log('##outcome Will make a call to notifyParent');
            helper.checkValidity(component, event, helper, stepWrapper);
        }
    },
    updateNotesRequired : function (component, event, helper) {
        let stepWrapper = component.get('v.stepWrapper');
        let selectedReason = component.find('reasonList').get('v.value');
        component.set('v.stepWrapper.reason', selectedReason);
        component.set('v.notesRequired', stepWrapper.notesRequiredMap[stepWrapper.outcome+';'+stepWrapper.reason]);
        helper.checkValidity(component, event, helper, stepWrapper);
    },
    checkNotesRequiredValidity : function (component, event, helper) {
        let stepWrapper = component.get('v.stepWrapper');
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