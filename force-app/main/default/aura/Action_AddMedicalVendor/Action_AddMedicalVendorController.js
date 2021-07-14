({
    doExecute: function (component, event, helper) {
        let params = event.getParam('arguments');
        component.set('v.callback', params.callback);
        if(params.mode == 'edit'){
                 component.set('v.recId',params.medicalId);
   
        }
        else{
          component.set('v.recId',null);  
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