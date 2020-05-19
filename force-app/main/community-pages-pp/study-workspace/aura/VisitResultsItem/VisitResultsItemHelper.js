(
    {
        roundValue: function(value) {
          return +(Math.round(value + "e+4")  + "e-4");
        },

        getExpectedRange: function(component, event, helper) {
            let wrapper = component.get('v.wrapper');
            let visitResultType = component.get('v.visitResultType');
            let expectedRange;

            if(wrapper.minValue != null && wrapper.maxValue != null) {
                expectedRange = wrapper.minValue + '-' + wrapper.maxValue;
            } else if(wrapper.minValue != null) {
                expectedRange = '> ' + wrapper.minValue;
            } else {
                expectedRange = '< ' + wrapper.maxValue;
            }
            if(expectedRange && wrapper.measurement) expectedRange += ' ' + wrapper.measurement;
            if(visitResultType === 'Biomarkers') expectedRange = $A.get('$Label.c.Biomarkers_Expected_Range');
            return expectedRange;
        },
    }
)