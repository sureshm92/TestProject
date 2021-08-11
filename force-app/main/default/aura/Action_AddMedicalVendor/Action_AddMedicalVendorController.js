({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        if(params.mode == 'edit' || params.mode == 'view' || params.mode == 'clone'){
                 component.set('v.recId',params.medicalId.value);
   
        }
        else{
          component.set('v.recId',null);
            component.set('v.headerTitle','Add Medical Vendor');
        }
        if(params.mode == 'view'){
            component.set('v.isView',true);
            component.set('v.headerTitle','View Medical Vendor');
        }
         if(params.mode == 'edit'){
            component.set('v.headerTitle','Edit Medical Vendor');
        }
         if(params.mode == 'clone'){
            component.set('v.headerTitle','Clone Medical Vendor');
            component.find("nameField").set("v.value", params.medicalId.label + ' Clone');
        }
        component.find('addMedicalVendorDialog').show();
        component.find('addMedicalVendorDialog').set('v.cancelCallback', function () {
            helper.resetForm(component);
        });
    },

    doClose: function (component, event, helper) {
        component.find('addMedicalVendorDialog').cancel();
    },

    doSave: function (component, event, hepler) {
        component.find('spinner').show();
        var fields = component.find("nameField");
        if(fields.get("v.fieldName") === 'Name' && $A.util.isEmpty(fields.get("v.value"))){
            fields.reportValidity();
            component.find('spinner').hide();
            }
        else{
          component.find('editForm').submit();  
          }
        
    },

    onSuccess: function (component, event, helper) {
        component.find('spinner').hide();
        component.find('addMedicalVendorDialog').hide();
        let callback = component.get('v.callback');
        if (callback) callback(event.getParams().response.id);
        helper.resetForm(component);
    },

    onError: function (component, event, helper) {
        component.find('spinner').hide();
    }
});