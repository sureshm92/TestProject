(
    {
        doInit : function(component, event, helper) {

            let wrapper = component.get('v.wrapper');
            let isVitals = component.get('v.isVitals');
            if(wrapper) {
                if(isVitals || wrapper.value == null || (wrapper.minValue == null && wrapper.maxValue == null)) {
                    component.set('v.showExpectedRange', false);
                } else {
                    if(wrapper.minValue != null) {
                        component.set('v.wrapper.minValue', helper.roundValue(wrapper.minValue));
                    }
                    if(wrapper.maxValue != null) {
                        component.set('v.wrapper.maxValue', helper.roundValue(wrapper.maxValue));
                    }
                    component.set('v.expectedRange', helper.getExpectedRange(component));
                }
            }
        },
    }
)