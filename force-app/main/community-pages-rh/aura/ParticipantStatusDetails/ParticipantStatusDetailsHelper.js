/**
 * Created by Andrii Kryvolap.
 */
({
    checkValidity : function (component, event, helper, stepWrapper){
        let isCurrentStepValid = true;
        let currentOutcomeSuccess = stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1;
        console.log('currentOutcomeSuccess ' + currentOutcomeSuccess);
        stepWrapper.formFieldGroups.forEach(function (group) {
            group.fields.forEach(function (field) {
                console.log(field.field + ' ' + field.value + ' required:' + field.required + ' valid:' + field.valid + ' dependent:' + field.dependent + ' dependentActive:' + field.dependentActive);
                if (isCurrentStepValid &&
                    ((field.required && ((!field.dependent && currentOutcomeSuccess) || (field.dependent && field.dependentActive))) && (!field.value || field.value.trim() === '')
                        || field.valid === false)) {
                    isCurrentStepValid = false;
                    console.log('isCurrentStepValid ' + isCurrentStepValid );
                }
            });
        });
        let notesRequired = component.get('v.notesRequired');
        isCurrentStepValid = isCurrentStepValid && ((stepWrapper.outcomeList === undefined || stepWrapper.outcomeList.length== 0)
            ||(stepWrapper.outcome === undefined || stepWrapper.outcome ==='')
            ||!notesRequired
            ||(stepWrapper.notes !== undefined && stepWrapper.notes !== '')
        );
        console.log('isCurrentStepValid ' + isCurrentStepValid );
        component.set('v.stepWrapper.isCurrentStepValid', isCurrentStepValid);
    },
    updateDependentFields : function (component, event, helper, stepWrapper, fieldName, value){
        debugger;
        if (stepWrapper.fieldDependencyMap.hasOwnProperty(fieldName)) {
            let dependentFields = stepWrapper.fieldDependencyMap[fieldName];
            for (let i = 0; i < stepWrapper.formFieldGroups.length; i++) {
                for (let j = 0; j < stepWrapper.formFieldGroups[i].fields.length; j++) {
                    for (let k = 0; k < dependentFields.length; k++) {
                        if (dependentFields[k].fieldName === stepWrapper.formFieldGroups[i].fields[j].field) {
                            if (dependentFields[k].controllingValue.indexOf(value) !== -1 || value === '') {
                                stepWrapper.formFieldGroups[i].fields[j].dependentActive = true;
                                if (stepWrapper.formFieldGroups[i].fields[j].populateFromDependent !== null && (stepWrapper.formFieldGroups[i].fields[j].value === null && stepWrapper.formFieldGroups[i].fields[j].value !== '')) {
                                    for (let k = 0; k < stepWrapper.formFieldGroups.length; k++) {
                                        for (let l = 0; l < stepWrapper.formFieldGroups[k].fields.length; l++) {
                                            if (stepWrapper.formFieldGroups[i].fields[j].populateFromDependent === stepWrapper.formFieldGroups[k].fields[l].field)
                                                stepWrapper.formFieldGroups[i].fields[j].value = stepWrapper.formFieldGroups[k].fields[l].value;
                                        }
                                    }
                                }
                            } else {
                                stepWrapper.formFieldGroups[i].fields[j].dependentActive = false;
                                // stepWrapper.formFieldGroups[i].fields[j].required = false;
                                if (stepWrapper.formFieldGroups[i].fields[j].strictDependency){
                                    stepWrapper.formFieldGroups[i].fields[j].value = '';
                                    helper.updateDependentFields(component, event, helper, stepWrapper,stepWrapper.formFieldGroups[i].fields[j].field , '');
                                //    TODO: rework in future for cascade updates
                                }
                            }
                       }
                    }
                }
            }
        }
    },
    populateChangedValue : function (component, event, helper, stepWrapper, fieldName, value, valid){
        for (let i = 0; i < stepWrapper.formFieldGroups.length; i++) {
            for (let j = 0; j < stepWrapper.formFieldGroups[i].fields.length; j++) {
                if(stepWrapper.formFieldGroups[i].fields[j].field === fieldName){
                    stepWrapper.formFieldGroups[i].fields[j].value = value;
                    stepWrapper.formFieldGroups[i].fields[j].valid = valid;
                }
            }
        }
    },
    populateFields : function (component, event, helper, stepWrapper, fieldMap) {
        for(let i = 0; i < stepWrapper.formFieldGroups.length; i++ ){
            for( let j = 0; j < stepWrapper.formFieldGroups[i].fields.length;j++){
                if(fieldMap.hasOwnProperty(stepWrapper.formFieldGroups[i].fields[j].field)){
                    stepWrapper.formFieldGroups[i].fields[j].value = fieldMap[stepWrapper.formFieldGroups[i].fields[j].field];
                }
            }
        }
    },
})