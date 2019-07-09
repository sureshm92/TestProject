(
    {
        doInit : function(component, event, helper) {

            let wrapper = component.get('v.wrapper');
            let isVitals = component.get('v.isVitals');
            if(wrapper) {
                if(isVitals || !wrapper.value || !wrapper.minValue || !wrapper.maxValue) {
                    component.set('v.showExpectedRange', false);
                }
            }
        },
    }
)