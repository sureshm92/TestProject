/**
 * Created by Andrii Kryvolap.
 */
({
    doInit: function (component, event, helper) {
        let field = component.get('v.field');
        component.set('v.previousValue', field.value)
    },
    onValueChange: function (component, event, helper) {
        let parent = component.get('v.parent');
        let field = component.get('v.field');
        let updateInProgress = component.get('v.updateInProgress');
        let previousValue = component.get('v.previousValue');
        if (!updateInProgress) {

            if (parent !== null && field !== undefined && field.value !== previousValue) {
                let populateFields = (previousValue === '' || previousValue === undefined || previousValue === null)
                    && field.value !== '' && field.populateFields !== undefined && field.populateFields !== null;
                parent.fieldChanged(field.field, field.value, field.valid, populateFields ? field.populateFields : null);
            }
        }

    },
    doCheckValidity: function (component, event, helper) {
        let field = component.get('v.field');
        let previousValue = component.get('v.previousValue');
        let validity;
        component.set('v.previousValue', field.value);
        if (field !== undefined && field.type !== 'picklist' && field.value !== previousValue) {
            let fieldInput = component.find('fieldInput');

            if (fieldInput !== undefined && !Array.isArray(fieldInput)) {
                validity = fieldInput.get('v.validity');
                if (validity !== undefined && (!validity.valueMissing || (field.value === '' && !field.readonly && field.required))) {
                    fieldInput.reportValidity();
                    field.valid = fieldInput.checkValidity();
                    component.set('v.field.valid', field.valid);
                }
            } else if (Array.isArray(fieldInput)) {
                fieldInput.forEach(function (input) {
                    let inputValidity = input.get('v.validity');
                    if (inputValidity !== undefined && (!inputValidity.valueMissing || (field.value === '' && !field.readonly && field.required))) {
                        input.reportValidity();
                        field.valid = input.checkValidity();
                        component.set('v.field.valid', field.valid);
                    }
                })
            }
        }
        if (field !== undefined && field.type === 'picklist' && field.validationMessageIfFalse !== undefined && field.validationMessageIfFalse !== null && field.validationMessageIfFalse !== '') {
            component.set('v.errorMessage', field.value === 'false'?field.validationMessageIfFalse:'');
        }
        component.set('v.previousValue', field.value);
    }
})