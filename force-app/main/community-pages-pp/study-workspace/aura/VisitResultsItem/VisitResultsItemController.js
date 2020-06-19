(
    {
        doInit: function (component, event, helper) {
            let displayedValue = component.get('v.displayedValue');
            let wrapper = component.get('v.wrapper');
            let visitResultType = component.get('v.visitResultType');
            if (wrapper) {
                if ((visitResultType === 'Vitals' && (wrapper.name === 'Weight' || wrapper.name === 'Height')) ||
                    (visitResultType !== 'Biomarkers' && (wrapper.minValue == null && wrapper.maxValue == null)) ||
                    (visitResultType === 'Biomarkers' && wrapper.value == null)) {
                    component.set('v.showExpectedRange', false);
                } else {
                    if (wrapper.minValue != null) {
                        component.set('v.wrapper.minValue', helper.roundValue(wrapper.minValue));
                    }
                    if (wrapper.maxValue != null) {
                        component.set('v.wrapper.maxValue', helper.roundValue(wrapper.maxValue));
                    }
                    if (visitResultType === 'Biomarkers') {
                        if (wrapper.value === 1) displayedValue = '+ ' + $A.get('$Label.c.Biomarkers_Positive');
                        else if (wrapper.value === -1) displayedValue = '- ' + $A.get('$Label.c.Biomarkers_Negative');
                        else if (wrapper.value === 0) displayedValue = $A.get('$Label.c.Biomarkers_Unknown');
                        component.set('v.displayedValue', displayedValue);
                    }
                    component.set('v.expectedRange', helper.getExpectedRange(component));
                }
            }
        },
    }
)