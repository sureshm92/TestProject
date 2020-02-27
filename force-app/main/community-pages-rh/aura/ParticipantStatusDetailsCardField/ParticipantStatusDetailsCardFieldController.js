/**
 * Created by Andrii Kryvolap.
 */
({
    onValueChange: function (component, event, helper) {
        let parent = component.get('v.parent');
        let field = component.get('v.field');
        if(parent!=null && field != undefined && field.type === 'picklist'){
            parent.fieldChanged(field.field, field.value);
        }
    },
    onBlur: function (component, event, helper) {
        let parent = component.get('v.parent');
        let field = component.get('v.field');
        if(parent!=null && field != undefined){
            let validity = event.getSource().get('v.validity');
            field.valid = validity.valid;
            component.set('v.field', field);
            parent.fieldChanged(field.field, field.value);
        }


    }
})