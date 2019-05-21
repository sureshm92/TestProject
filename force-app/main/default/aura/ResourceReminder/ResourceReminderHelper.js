/**
 * Created by Yehor Dobrovolskyi
 */({
    subscribe: function (component, event, helper) {
        const empApi = component.find('empApi');
        const channel = component.get('v.channel');
        const replayId = -1;
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            if (eventReceived.data.payload.ResourceId__c === component.get('v.recordId')) {
                helper.remind(component, event);
            }
            console.log('Received event ', JSON.stringify(eventReceived));
        }))
            .then(subscription => {
                console.log('Subscribed to channel ', subscription.channel);
            });
    },

    remind: function (component, event) {
        let action = component.get('c.getReminders');
        if (action) {
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
        }

    },

})