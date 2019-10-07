(
    {
        roundValue: function(value) {
          return +(Math.round(value + "e+4")  + "e-4");
        },

        getExpectedRange: function(component, event, helper) {
            let wrapper = component.get('v.wrapper');
            let expectedRange;
            if(wrapper.minValue != null && wrapper.maxValue != null) {
                expectedRange = wrapper.minValue + '-' + wrapper.maxValue;
            } else if(wrapper.minValue != null) {
                expectedRange = '> ' + wrapper.minValue;
            } else {
                expectedRange = '< ' + wrapper.maxValue;
            }
            return expectedRange + ' ' + wrapper.measurement;
        },
    }
)