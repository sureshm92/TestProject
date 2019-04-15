/**
 * Created by Yehor Dobrovolskyi
 */
({
    valueChange: function (component, event, helper) {
        component.set('v.bypass', false);
        let value = event.getSource().get('v.value');
        if (value) {
            communityService.executeAction(component, 'searchConditionOfInterest', {
                nameTA : value
            }, function (returnValue) {
                let coiList = component.get('v.conditionsOfInterest');
                let coiWrappers = returnValue;
                coiWrappers.forEach(coiWrapper => {
                    if (coiList.some(coiEl => coiEl.coi.Therapeutic_Area__r.Id === coiWrapper.coi.Therapeutic_Area__r.Id)) {
                        coiWrapper.isSelected = true;
                    }
                });
                component.set('v.displayedItems', coiWrappers);
            })
        } else {
            let arr = [];
            component.set('v.displayedItems', arr);
        }
    },
})