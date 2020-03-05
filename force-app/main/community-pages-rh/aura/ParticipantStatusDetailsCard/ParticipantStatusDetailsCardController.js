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
    doSaveChanges : function (component, event, helper) {
        var parent = component.get('v.parent');
        parent.doUpdatePatientStatus();
    },
    doCheckDependentFields : function (component, event, helper) {

        var stepWrapper = component.get('v.stepWrapper');
        var updateInProgress = component.get('v.updateInProgress');
        if(!updateInProgress) {
            component.set('v.updateInProgress', true);
            helper.checkValidity(component, event, helper, stepWrapper);
            var params = event.getParam('arguments');
            var fieldName = params.fieldName;
            if (stepWrapper.fieldDependencyMap.hasOwnProperty(fieldName)) {
                var dependentFields = stepWrapper.fieldDependencyMap[fieldName];
                for (var i = 0; i < stepWrapper.formFieldGroups.length; i++) {
                    for (var j = 0; j < stepWrapper.formFieldGroups[i].fields.length; j++) {
                        if (dependentFields.indexOf(stepWrapper.formFieldGroups[i].fields[j].field) != -1) {
                            if (params.value === 'false') {
                                // stepWrapper.formFieldGroups[i].fields[j].required = false;
                                stepWrapper.formFieldGroups[i].fields[j].value = '';
                                stepWrapper.formFieldGroups[i].fields[j].readonly = true;
                            } else {
                                // stepWrapper.formFieldGroups[i].fields[j].required = true;
                                debugger;
                                stepWrapper.formFieldGroups[i].fields[j].readonly = false;
                                if (stepWrapper.formFieldGroups[i].fields[j].populateFromDependent !== null) {
                                    for (var k = 0; k < stepWrapper.formFieldGroups.length; k++) {
                                        for (var l = 0; l < stepWrapper.formFieldGroups[k].fields.length; l++) {
                                            if (stepWrapper.formFieldGroups[i].fields[j].populateFromDependent === stepWrapper.formFieldGroups[k].fields[l].field)
                                                stepWrapper.formFieldGroups[i].fields[j].value = stepWrapper.formFieldGroups[k].fields[l].value;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    component.set('v.stepWrapper.formFieldGroups', stepWrapper.formFieldGroups);
                }
            }
            component.set('v.updateInProgress', false);
        }
    },
    doPopulateFields : function (component, event, helper) {
        let stepWrapper = component.get('v.stepWrapper');
        let params = event.getParam('arguments');
        let fieldMap = params.fieldMap;
        for(let i = 0; i < stepWrapper.formFieldGroups.length; i++ ){
            for( let j = 0; j < stepWrapper.formFieldGroups[i].fields.length;j++){
                if(fieldMap.hasOwnProperty(stepWrapper.formFieldGroups[i].fields[j].field)){
                    stepWrapper.formFieldGroups[i].fields[j].value = fieldMap[stepWrapper.formFieldGroups[i].fields[j].field];
                }
            }
        }
        component.set('v.stepWrapper.formFieldGroups', stepWrapper.formFieldGroups);
    },
})