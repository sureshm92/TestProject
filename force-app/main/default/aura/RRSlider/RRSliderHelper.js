(
    {
        changeValue : function(component, event, helper) {

            let value = component.get('v.value'),
                minValue = component.get('v.minValue'),
                maxValue = component.get('v.maxValue');

            value = helper.getValidValue(value, minValue, maxValue);
            component.set('v.value', value);

            let actualValue = (value - minValue) / (maxValue - minValue);
            try {
                let track = component.find('track').getElement(),
                    trackFilled = component.find('track-filled').getElement(),
                    knob = component.find('knob').getElement(),
                    valueBox = component.find('valueBox').getElement(),
                    barWidth = track.offsetWidth,
                    valueInPx = actualValue * barWidth;
                trackFilled.style.setProperty('width', actualValue * 100 + '%');
                knob.style.setProperty('left', helper.getShift(barWidth,valueInPx, knob) + 'px');
                valueBox.style.setProperty('left', helper.getShift(barWidth,valueInPx, valueBox) + 'px');
            } catch(err) {
                helper.hideComponent(component, err);
                return;
            }
        },

        getValidValue : function(value, minValue, maxValue) {
            return value < minValue ? minValue : (value > maxValue ? maxValue : value);
        },

        getShift : function(totalWidth, widthInPx, element) {
            let shift = widthInPx - element.offsetWidth/2;
            let subtractedWidth = totalWidth - element.offsetWidth
            if(shift > subtractedWidth) {
                return subtractedWidth;
            }
            if(shift < 0) {
                return 0;
            }
            return shift;
        },

        hideComponent : function(component, message) {
            component.set('v.hidden', true);
            console.log(message);
        },
    }
)