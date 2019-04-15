/**
 * Created by Yehor Dobrovolskyi
 */
({
    valueChange: function (component, event, helper) {
        component.set('v.bypass', false);
        let value = event.getSource().get('v.value');
        if (value) {
            // communityService.executeAction(component, 'searchConditionOfInterest', {
            //     nameTA : value
            // }, function (returnValue) {
            //     component.set('v.therapeuticAreas', returnValue);
            // })
            var action = component.get("c.searchConditionOfInterest");
            action.setParams({nameTA: value});
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    let taList = component.get('v.conditionsOfInterest');
                    let coiWrappers = response.getReturnValue();
                    coiWrappers.forEach(taWrapper => {
                        if (taList.some(ta => ta.coi.Therapeutic_Area__r.Id === taWrapper.coi.Therapeutic_Area__r.Id)) {
                            taWrapper.isSelected = true;
                        }
                    });
                    component.set('v.displayedItems', coiWrappers);
                } else if (state === "ERROR") {
                    var errors = response.getError();
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
        } else {
            let arr = [];
            component.set('v.displayedItems', arr);
        }
    },
})