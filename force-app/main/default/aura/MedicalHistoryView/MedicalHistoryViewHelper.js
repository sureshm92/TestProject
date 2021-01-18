({
   showToast: function (component, event, helper) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: 'Warning',
            message: $A.get('$Label.c.Medical_Preview_Error_Message')
        });
        toastEvent.fire();
    },
})