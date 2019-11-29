({

    handleSuccess: function (component, event, helper) {
        let payload = event.getParams().response;
        component.set('v.record', null);
        component.set('v.recordId', null);
        let submitAction = component.get('v.onSubmit');
        if (submitAction) $A.enqueueAction(submitAction);
    },

    onSubmit : function(component, event, helper) {
        component.find('editForm').submit();
    }

});