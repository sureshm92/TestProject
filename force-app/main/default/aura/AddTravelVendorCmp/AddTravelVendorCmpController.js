({

    handleSuccess: function (component, event, helper) {
        let payload = event.getParams().response;
        let newRecord = {
            'Id' : payload.id,
            'Name' : payload.fields.Name.value
        };
        component.set('v.record', newRecord);
        let submitAction = component.get('v.onSubmit');
        if (submitAction) $A.enqueueAction(submitAction);
    },

    onSubmit : function(component, event, helper) {
        component.find('editForm').submit();
    }

});