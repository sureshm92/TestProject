/**
 * Created by Andrii Kryvolap.
 */
({
    checkValidity : function (component, event, helper, stepWrapper){
        var isValid = true;
        var currentOutcomeSuccess = stepWrapper.successOutcomes.indexOf(stepWrapper.outcome)!== -1;
        console.log('currentOutcomeSuccess ' + currentOutcomeSuccess);
        stepWrapper.formFieldGroups.forEach(function (group) {
            group.fields.forEach(function (field) {
                console.log(field.field + ' ' + field.value + ' required:' + field.required);
                if (isValid && (field.required && (currentOutcomeSuccess || field.dependent)) && (!field.value || field.value.trim() === '')) {
                    isValid = false;
                }
            });
        });
        var notesRequired = component.get('v.notesRequired');
        debugger;
        isValid = isValid && ((stepWrapper.outcomeList === undefined || stepWrapper.outcomeList.length== 0)
            ||(stepWrapper.outcome === undefined || stepWrapper.outcome ==='')
            ||!notesRequired
            ||(stepWrapper.notes !== undefined && stepWrapper.notes !== '')
        );
        console.log('isValid ' + isValid );
        component.set('v.isValid', isValid); //TODO: add and(!empty(v.stepWrapper.outcomeList),!empty(v.stepWrapper.outcome),v.notesRequired,empty(v.stepWrapper.notes))))
    }
})