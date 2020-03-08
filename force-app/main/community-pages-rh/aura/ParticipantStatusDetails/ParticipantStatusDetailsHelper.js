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
                console.log(field.field + ' ' + field.value + ' required:' + field.required + ' valid:' + field.valid + ' dependent:' + field.dependent);
                if (isCurrentStepValid &&
                    (((field.required && !field.readonly) && (currentOutcomeSuccess || field.dependent)) && (!field.value || field.value.trim() === '')
                        || field.valid === false)) {
                    isCurrentStepValid = false;
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
        if (stepWrapper.fieldDependencyMap.hasOwnProperty(fieldName)) {
            let dependentFields = stepWrapper.fieldDependencyMap[fieldName];
            for (let i = 0; i < stepWrapper.formFieldGroups.length; i++) {
                for (let j = 0; j < stepWrapper.formFieldGroups[i].fields.length; j++) {
                    if (dependentFields.indexOf(stepWrapper.formFieldGroups[i].fields[j].field) != -1) {
                        if (value === 'false') {
                            // stepWrapper.formFieldGroups[i].fields[j].required = false;
                            stepWrapper.formFieldGroups[i].fields[j].value = '';
                            stepWrapper.formFieldGroups[i].fields[j].readonly = true;
                        } else {
                            // stepWrapper.formFieldGroups[i].fields[j].required = true;
                            stepWrapper.formFieldGroups[i].fields[j].readonly = false;
                            if (stepWrapper.formFieldGroups[i].fields[j].populateFromDependent !== null && (stepWrapper.formFieldGroups[i].fields[j].value === null || stepWrapper.formFieldGroups[i].fields[j].value === '')) {
                                for (let k = 0; k < stepWrapper.formFieldGroups.length; k++) {
                                    for (let l = 0; l < stepWrapper.formFieldGroups[k].fields.length; l++) {
                                        if (stepWrapper.formFieldGroups[i].fields[j].populateFromDependent === stepWrapper.formFieldGroups[k].fields[l].field)
                                            stepWrapper.formFieldGroups[i].fields[j].value = stepWrapper.formFieldGroups[k].fields[l].value;
                                    }
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