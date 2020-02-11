/**
 * Created by Andrii Kryvolap.
 */
({
    notifyParent: function (component, event, helper) {
        var parent = component.get('v.parent');
        var field = component.get('v.field');
        if(parent!=null && field != undefined){
            parent.fieldChanged(field.field, field.value);
        }
    },
})