(
    {
        changeValue : function(component, event, helper) {

            let value = component.get('v.value'),
                minValue = component.get('v.minValue'),
                maxValue = component.get('v.maxValue');
            if(value == null) {
                component.set('v.showValueBox', false);
                component.set('v.showKnob', false);
                return;
            }
            if(minValue == null && maxValue == null) {
                minValue = value - 10;
                maxValue = value + 10;
            } else if(minValue == null) {
                minValue = maxValue - Math.abs((maxValue - value) * 2);
            } else if(maxValue == null) {
                maxValue = minValue + Math.abs((value - minValue) * 2);
            }
            component.set('v.showFilledTrackPrivate', component.get('v.showFilledTrack'));
            component.set('v.valueInBox', this.roundValue(value));
            value = helper.getValidValue(value, minValue, maxValue);
            component.set('v.value', value);

            let actualValue = (value - minValue) / (maxValue - minValue);
            try {
                let track = component.find('track').getElement(),
                    knob = component.find('knob').getElement(),
                    valueBox = component.find('valueBox').getElement(),
                    barWidth = track.offsetWidth,
                    valueInPx = actualValue * barWidth;
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
            let subtractedWidth = totalWidth - element.offsetWidth;
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

        roundValue: function(value) {
          return +(Math.round(value + "e+4")  + "e-4");
        },
    }
)