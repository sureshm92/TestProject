/**
 * Created by Andrii Kryvolap.
 */
({
    doInit : function (component, event, helper) {
        let field = component.get('v.field');
        component.set('v.previousValue', field.value);
    },
    onValueChange: function (component, event, helper) {
        let parent = component.get('v.parent');
        let field = component.get('v.field');
        if(field!==undefined && field.type !== 'picklist'){
            let fieldInput = component.find('fieldInput');
            if(fieldInput!== undefined && !Array.isArray(fieldInput )){
                fieldInput.reportValidity();
                component.set('v.field.valid', fieldInput.checkValidity());
            }
            else if(Array.isArray(fieldInput)){
                fieldInput.forEach( function (input) {
                    input.reportValidity();
                })
            }

        }
        if(parent!=null && field != undefined && field.type === 'picklist'){
            parent.fieldChanged(field.field, field.value);
        }
    },
    onBlur: function (component, event, helper) {
        let parent = component.get('v.parent');
        let field = component.get('v.field');
        let previousValue = component.get('v.previousValue');
        if(parent!=null && field !== undefined){
            let validity = event.getSource().get('v.validity');
            component.set('v.field.valid', validity.valid);
            parent.fieldChanged(field.field, field.value);
        }
        if((previousValue === '' || previousValue === undefined || previousValue === null) && (field.value !== undefined
            && field.value !== null && field.value !== '' && field.populateFields !== undefined && field.populateFields !== null)){
            parent.populateFields(field.populateFields);
        }
        component.set('v.previousValue', field.value);
    }
})