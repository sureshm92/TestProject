/**
 * Created by Yehor Dobrovolskyi
 */({
    doInit: function (component, event, helper) {
        let action = component.get('c.getReminders');
        action.setParams({
            resId: component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set('v.reminders',response.getReturnValue());
            }
            else if (state === "ERROR") {
                let errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },

    onLog: function (component, event, helper) {
        console.log('test');

    }
})