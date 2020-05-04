(
    {
        doInit : function(component, event, helper) {

            let wrapper = component.get('v.wrapper');
            let visitResultType = component.get('v.visitResultType');
            if(wrapper) {
                if((visitResultType=== 'Vitals') || wrapper.value == null || (wrapper.minValue == null && wrapper.maxValue == null)) {
                    component.set('v.showExpectedRange', false);
                } else if (visitResultType === 'Labs'){
                    if(wrapper.minValue != null) {
                        component.set('v.wrapper.minValue', helper.roundValue(wrapper.minValue));
                    }
                    if(wrapper.maxValue != null) {
                        component.set('v.wrapper.maxValue', helper.roundValue(wrapper.maxValue));
                    }
                    component.set('v.expectedRange', helper.getExpectedRange(component));
                } else {
                    //TODO results for biomarkers
                }
            }
        },
    }
)