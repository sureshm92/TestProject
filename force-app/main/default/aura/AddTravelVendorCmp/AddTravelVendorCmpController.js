({

    handleSuccess: function (component, event, helper) {
        let payload = event.getParams().response;
        component.set('v.record', payload);
        let evt = component.getEvent('vendorCreated');
        evt.fire();
    },

    onSubmit : function(component, event, helper) {
        component.find('editForm').submit();
    }

});