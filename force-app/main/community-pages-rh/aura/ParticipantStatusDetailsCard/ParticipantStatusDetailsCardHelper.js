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
                    ((field.required && ((!field.dependent && currentOutcomeSuccess) || (field.dependent && field.dependentActive))) && (!field.value || field.value.trim() === '')
                        || field.valid === false)) {
                    isCurrentStepValid = false;
                }
            });
        });
        let notesRequired = component.get('v.notesRequired');
        isCurrentStepValid = isCurrentStepValid && ((stepWrapper.outcomeList === undefined || stepWrapper.outcomeList.length== 0)
            ||(stepWrapper.outcome === undefined || stepWrapper.outcome ==='')
            ||!notesRequired
            ||(stepWrapper.notes !== undefined && stepWrapper.notes.trim() !== '')
        );
        console.log('isCurrentStepValid ' + isCurrentStepValid );
        component.set('v.stepWrapper.isCurrentStepValid', isCurrentStepValid);
        let partInfoForm = component.get('v.partInfoForm');
        partInfoForm.statusDetailValidityCheck();
    },
})